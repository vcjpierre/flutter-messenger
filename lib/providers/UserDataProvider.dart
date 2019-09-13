import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_messenger/config/Constants.dart';
import 'package:flutter_messenger/config/Paths.dart';
import 'package:flutter_messenger/models/Contact.dart';
import 'package:flutter_messenger/models/User.dart';
import 'package:flutter_messenger/providers/BaseProviders.dart';
import 'package:flutter_messenger/utils/Exceptions.dart';
import 'package:flutter_messenger/utils/SharedObjects.dart';

class UserDataProvider extends BaseUserDataProvider {
  final Firestore fireStoreDb;

  UserDataProvider({Firestore fireStoreDb})
      : fireStoreDb = fireStoreDb ?? Firestore.instance;

  @override
  Future<User> saveDetailsFromGoogleAuth(FirebaseUser user) async {
    DocumentReference ref = fireStoreDb.collection(Paths.usersPath).document(user
        .uid); //reference of the user's document node in database/users. This node is created using uid
    final bool userExists =
        !await ref.snapshots().isEmpty; // check if user exists or not
    var data = {
      //add details received from google auth
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
    };
    if (!userExists) {
      // if user entry exists then we would not want to override the photo url with the one received from googel auth
      data['photoUrl'] = user.photoUrl;
    }
    ref.setData(data, merge: true); // set the data
    final DocumentSnapshot currentDocument =
        await ref.get(); // get updated data reference
    return User.fromFirestore(
        currentDocument); // create a user object and return
  }

  @override
  Future<User> saveProfileDetails(
      String profileImageUrl, int age, String username) async {
    String uid = SharedObjects.prefs.get(Constants.sessionUid);
    //get a reference to the map
    DocumentReference mapReference =
        fireStoreDb.collection(Paths.usernameUidMapPath).document(username);
    var mapData = {'uid': uid};
    //map the uid to the username
    mapReference.setData(mapData);

    DocumentReference ref = fireStoreDb.collection(Paths.usersPath).document(
        uid); //reference of the user's document node in database/users. This node is created using uid
    var data = {
      'photoUrl': profileImageUrl,
      'age': age,
      'username': username,
    };
    ref.setData(data, merge: true); // set the photourl, age and username
    final DocumentSnapshot currentDocument =
        await ref.get(); // get updated data back from firestore
    return User.fromFirestore(
        currentDocument); // create a user object and return it
  }

  @override
  Future<bool> isProfileComplete() async {
    DocumentReference ref = fireStoreDb.collection(Paths.usersPath).document(
        SharedObjects.prefs
            .get(Constants.sessionUid)); // get reference to the user/ uid node
    final DocumentSnapshot currentDocument = await ref.get();
    return (currentDocument != null &&
        currentDocument.exists &&
        currentDocument.data.containsKey('username') &&
        currentDocument.data.containsKey(
            'age')); // check if it exists, if yes then check if username and age field are there or not. If not then profile incomplete else complete
  }

  @override
  Stream<List<Contact>> getContacts() {
    CollectionReference userRef = fireStoreDb.collection(Paths.usersPath);
    DocumentReference ref =
        userRef.document(SharedObjects.prefs.get(Constants.sessionUid));
   // DocumentSnapshot documentSnapshot = await ref.get();


    return ref.snapshots().transform(StreamTransformer<DocumentSnapshot, List<Contact>>.fromHandlers(handleData: (documentSnapshot, sink) async{
      List<String> contacts;
      if (documentSnapshot.data['contacts'] == null) {
        ref.updateData({'contacts': []});
        contacts = List();
      } else {
        contacts = List.from(documentSnapshot.data['contacts']);
      }
      List<Contact> contactList = List();
      for (String username in contacts) {
        print(username);
        String uid = await getUidByUsername(username);
        DocumentSnapshot contactSnapshot = await userRef.document(uid).get();
        contactList.add(Contact.fromFirestore(contactSnapshot));
      }
      sink.add(contactList);
    }));





//    List<String> contacts;
//    if (documentSnapshot.data['contacts'] == null) {
//      ref.updateData({'contacts': []});
//      contacts = List();
//    } else {
//      contacts = List.from(documentSnapshot.data['contacts']);
//    }
//    List<Contact> contactList = List();
//    for (String username in contacts) {
//      print(username);
//      String uid = await getUidByUsername(username);
//      DocumentSnapshot contactSnapshot = await userRef.document(uid).get();
//      contactList.add(Contact.fromFirestore(contactSnapshot));
//    }
//    return contactList;
  }

  @override
  Future<void> addContact(String username) async {
    await getUser(username);
    //create a node with the username provided in the contacts collection
    DocumentReference ref = fireStoreDb
        .collection(Paths.usersPath)
        .document(SharedObjects.prefs.get(Constants.sessionUid));
    //await to fetch user details of the username provided and set data
    var documentSnapshot = await ref.get();
    print(documentSnapshot.data);
    List<String> contacts = documentSnapshot.data['contacts'] != null
        ? List.from(documentSnapshot.data['contacts'])
        : List();
    if (contacts.contains(username)) {
      throw ContactAlreadyExistsException();
    }
    contacts.add(username);
    ref.updateData({'contacts': contacts});
  }

  @override
  Future<User> getUser(String username) async {
    String uid = await getUidByUsername(username);
    DocumentReference ref =
        fireStoreDb.collection(Paths.usersPath).document(uid);
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      return User.fromFirestore(snapshot);
    } else {
      throw UserNotFoundException();
    }
  }

  @override
  Future<String> getUidByUsername(String username) async {
    //get reference to the mapping using username
    DocumentReference ref =
        fireStoreDb.collection(Paths.usernameUidMapPath).document(username);
    DocumentSnapshot documentSnapshot = await ref.get();
    print(documentSnapshot.exists);
    //check if uid mapping for supplied username exists
    if (documentSnapshot != null && documentSnapshot.exists && documentSnapshot.data['uid']!=null) {
      return documentSnapshot.data['uid'];
    } else {
      throw UsernameMappingUndefinedException();
    }
  }
}
