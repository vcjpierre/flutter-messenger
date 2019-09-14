import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_messenger/config/Paths.dart';
import 'package:flutter_messenger/models/Chat.dart';
import 'package:flutter_messenger/models/Message.dart';

import 'BaseProviders.dart';

class ChatProvider extends BaseChatProvider{
  final Firestore fireStoreDb;

  ChatProvider({Firestore fireStoreDb})
      : fireStoreDb = fireStoreDb ?? Firestore.instance;

  @override
  Stream<List<Chat>> getChats() {
    return null;
  }

  @override
  Stream<List<Message>> getMessages(String chatId)  {
    print('here');
    DocumentReference chatDocRef = fireStoreDb.collection(Paths.chatsPath).document(chatId);
    CollectionReference messagesCollection = chatDocRef.collection(Paths.messagesPath);
//    return messagesCollection.snapshots().map((querySnapshot){
//      print('insideeeeeeeeeeeeeeeeeeeeeee');
//      List<Message> messages = List();
//      for ( DocumentSnapshot document in querySnapshot.documents){
//        print(document.data);
//        messages.add(Message.fromFireStore(document));
//      }
//      return messages;
//    });
    return messagesCollection.snapshots().transform(
        StreamTransformer<QuerySnapshot, List<Message>>.fromHandlers(
            handleData: (QuerySnapshot querySnapshot,EventSink<List<Message>> sink) =>mapDocumentToMessage(querySnapshot,sink)));
  }

  void mapDocumentToMessage(QuerySnapshot querySnapshot,EventSink sink) async{
    print('inside');
    print(querySnapshot);
    List<Message> messages = List();
    for ( DocumentSnapshot document in querySnapshot.documents){
      print(document.data);
      messages.add(Message.fromFireStore(document));
    }
    sink.add(messages);
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    DocumentReference chatDocRef = fireStoreDb.collection(Paths.chatsPath).document(chatId);
    CollectionReference messagesCollection = chatDocRef.collection(Paths.messagesPath);
    messagesCollection.add(message.toMap());
  }


}