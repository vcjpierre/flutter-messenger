import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_messenger/models/User.dart';
import 'package:flutter_messenger/repositories/ChatRepository.dart';
import 'package:flutter_messenger/repositories/UserDataRepository.dart';
import 'package:flutter_messenger/utils/Exceptions.dart';
import './Bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  UserDataRepository userDataRepository;
  ChatRepository chatRepository;
  StreamSubscription subscription;

  ContactsBloc({this.userDataRepository, this.chatRepository})
      : assert(userDataRepository != null),
        assert(chatRepository != null);

  @override
  ContactsState get initialState => InitialContactsState();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is FetchContactsEvent) {
      try {
        yield FetchingContactsState();
        subscription?.cancel();
        subscription = userDataRepository.getContacts().listen((contacts) => {
              print('dispatching $contacts'),
              dispatch(ReceivedContactsEvent(contacts))
            });
      } on MessengerException catch (exception) {
        print(exception.errorMessage());
        yield ErrorState(exception);
      }
    }
    if (event is ReceivedContactsEvent) {
      print('Received');
      //  yield FetchingContactsState();
      yield FetchedContactsState(event.contacts);
    }
    if (event is AddContactEvent) {
      userDataRepository.getUser(event.username);
      yield* mapAddContactEventToState(event.username);
    }
    if (event is ClickedContactEvent) {
      yield ClickedContactState(event.contact);
    }
  }

  Stream<ContactsState> mapFetchContactsEventToState() async* {
    try {
      yield FetchingContactsState();
      subscription?.cancel();
      subscription = userDataRepository.getContacts().listen((contacts) => {
            print('dispatching $contacts'),
            dispatch(ReceivedContactsEvent(contacts))
          });
    } on MessengerException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ContactsState> mapAddContactEventToState(String username) async* {
    try {
      yield AddContactProgressState();
      await userDataRepository.addContact(username);
      User user = await userDataRepository.getUser(username);
      await chatRepository.createChatIdForContact(user);
      yield AddContactSuccessState();
      //dispatch(FetchContactsEvent());
    } on MessengerException catch (exception) {
      print(exception.errorMessage());
      yield AddContactFailedState(exception);
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
