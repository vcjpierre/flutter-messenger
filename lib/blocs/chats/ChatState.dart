import 'package:equatable/equatable.dart';
import 'package:flutter_messenger/models/Chat.dart';
import 'package:flutter_messenger/models/Message.dart';
import 'package:flutter_messenger/models/User.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ChatState extends Equatable {
  ChatState([List props = const <dynamic>[]]) : super(props);
}

class InitialChatState extends ChatState {}

class FetchedChatListState extends ChatState {
  final List<Chat> chatList;

  FetchedChatListState(this.chatList) : super([chatList]);

  @override
  String toString() => 'FetchedChatListState';
}

class FetchedMessagesState extends ChatState {
  final List<Message> messages;
  final String username;
  final isPrevious;
  FetchedMessagesState(this.messages,this.username, {this.isPrevious}) : super([messages,username,isPrevious]);

  @override
  String toString() => 'FetchedMessagesState {messages: ${messages.length}, username: $username, isPrevious: $isPrevious}';
}

class ErrorState extends ChatState {
  final Exception exception;

  ErrorState(this.exception) : super([exception]);

  @override
  String toString() => 'ErrorState';
}

class FetchedContactDetailsState extends ChatState {
  final User user;
  final String username;
  FetchedContactDetailsState(this.user,this.username) : super([user,username]);

  @override
  String toString() => 'FetchedContactDetailsState';
}

class PageChangedState extends ChatState {
  final int index;
  final Chat activeChat;
  PageChangedState(this.index, this.activeChat) : super([index, activeChat]);

  @override
  String toString() => 'PageChangedState';
}
