import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:flutter_messenger/blocs/chats/Bloc.dart';
import 'package:flutter_messenger/config/Constants.dart';
import 'package:flutter_messenger/config/Paths.dart';
import 'package:flutter_messenger/models/Message.dart';
import 'package:flutter_messenger/models/User.dart';
import 'package:flutter_messenger/repositories/ChatRepository.dart';
import 'package:flutter_messenger/repositories/StorageRepository.dart';
import 'package:flutter_messenger/repositories/UserDataRepository.dart';
import 'package:flutter_messenger/utils/Exceptions.dart';
import 'package:flutter_messenger/utils/SharedObjects.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final UserDataRepository userDataRepository;
  final StorageRepository storageRepository;
  Map<String, StreamSubscription> messagesSubscriptionMap = Map();
  StreamSubscription chatsSubscription;
  String activeChatId;

  ChatBloc(
      {this.chatRepository, this.userDataRepository, this.storageRepository})
      : assert(chatRepository != null),
        assert(userDataRepository != null),
        assert(storageRepository != null);

  @override
  ChatState get initialState => InitialChatState();

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    print(event);
    if (event is FetchChatListEvent) {
      yield* mapFetchChatListEventToState(event);
    }
    if (event is ReceivedChatsEvent) {
      yield FetchedChatListState(event.chatList);
    }
    if (event is PageChangedEvent) {
      activeChatId = event.activeChat.chatId;
      yield PageChangedState(event.index, event.activeChat);
    }
    if (event is FetchConversationDetailsEvent) {
      dispatch(FetchMessagesEvent(event.chat));
      yield* mapFetchConversationDetailsEventToState(event);
    }
    if (event is FetchMessagesEvent) {
      yield* mapFetchMessagesEventToState(event);
    }
    if (event is FetchPreviousMessagesEvent) {
      yield* mapFetchPreviousMessagesEventToState(event);
    }
    if (event is ReceivedMessagesEvent) {
      yield FetchedMessagesState(event.messages, event.username,
          isPrevious: false);
    }
    if (event is SendTextMessageEvent) {
      Message message = TextMessage(
          event.message,
          DateTime.now().millisecondsSinceEpoch,
          SharedObjects.prefs.getString(Constants.sessionName),
          SharedObjects.prefs.getString(Constants.sessionUsername));
      await chatRepository.sendMessage(activeChatId, message);
    }
    if (event is SendAttachmentEvent) {
      await mapSendAttachmentEventToState(event);
    }

    if (event is ToggleEmojiKeyboardEvent) {
      yield ToggleEmojiKeyboardState(event.showEmojiKeyboard);
    }
  }

  Stream<ChatState> mapFetchChatListEventToState(
      FetchChatListEvent event) async* {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = chatRepository
          .getChats()
          .listen((chats) => dispatch(ReceivedChatsEvent(chats)));
    } on MessengerException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchMessagesEventToState(
      FetchMessagesEvent event) async* {
    try {
      yield InitialChatState();
      String chatId =
          await chatRepository.getChatIdByUsername(event.chat.username);
      //  print('mapFetchMessagesEventToState');
      //  print('MessSubMap: $messagesSubscriptionMap');
      StreamSubscription messagesSubscription = messagesSubscriptionMap[chatId];
      messagesSubscription?.cancel();
      messagesSubscription = chatRepository.getMessages(chatId).listen(
          (messages) =>
              dispatch(ReceivedMessagesEvent(messages, event.chat.username)));
      messagesSubscriptionMap[chatId] = messagesSubscription;
    } on MessengerException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchPreviousMessagesEventToState(
      FetchPreviousMessagesEvent event) async* {
    try {
      String chatId =
          await chatRepository.getChatIdByUsername(event.chat.username);
      final messages =
          await chatRepository.getPreviousMessages(chatId, event.lastMessage);
      yield FetchedMessagesState(messages, event.chat.username,
          isPrevious: true);
    } on MessengerException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchConversationDetailsEventToState(
      FetchConversationDetailsEvent event) async* {
    User user = await userDataRepository.getUser(event.chat.username);
    yield FetchedContactDetailsState(user, event.chat.username);
  }

  Future mapSendAttachmentEventToState(SendAttachmentEvent event) async {
    File file = event.file;
    String fileName = basename(file.path);
    String url = await storageRepository.uploadFile(
        file, Paths.getAttachmentPathByFileType(event.fileType));
    String username = SharedObjects.prefs.getString(Constants.sessionUsername);
    String name = SharedObjects.prefs.getString(Constants.sessionName);
    print('File Name: $fileName');
    Message message;
    if (event.fileType == FileType.IMAGE)
      message = ImageMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    else if (event.fileType == FileType.VIDEO)
      message = VideoMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    else
      message = FileMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    await chatRepository.sendMessage(event.chatId, message);
  }

  @override
  void dispose() {
    messagesSubscriptionMap.forEach((_, subscription) => subscription.cancel());
    super.dispose();
  }
}
