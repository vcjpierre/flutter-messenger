import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Message {
  int timeStamp;
  String senderName;
  String senderUsername;

  Message(this.timeStamp, this.senderName, this.senderUsername);

  factory Message.fromFireStore(DocumentSnapshot doc) {
    final int type = doc.data['type'];
    Message message;
    switch (type) {
      case 0:
        message = TextMessage.fromFirestore(doc);
        break;
      case 1:
        message = ImageMessage.fromFirestore(doc);
        break;
      case 2:
        message = VideoMessage.fromFirestore(doc);
        break;
      case 3:
        message = FileMessage.fromFirestore(doc);
    }
    return message;
  }

  Map<String, dynamic> toMap();
}

class TextMessage extends Message {
  String text;

  TextMessage(this.text, timeStamp, senderName, senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory TextMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return TextMessage(data['text'], data['timeStamp'], data['senderName'],
        data['senderUsername']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['text'] = text;
    map['timeStamp'] = timeStamp;
    map['senderName'] = senderName;
    map['senderUsername'] = senderUsername;
    map['type'] = 0;
    return map;
  }
}

class ImageMessage extends Message {
  String imageUrl;

  ImageMessage(this.imageUrl, timeStamp, senderName, senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory ImageMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return ImageMessage(data['imageUrl'], data['timeStamp'], data['senderName'],
        data['senderUsername']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['imageUrl'] = imageUrl;
    map['timeStamp'] = timeStamp;
    map['senderName'] = senderName;
    map['senderUsername'] = senderUsername;
    map['type'] = 1;
    return map;
  }
}

class VideoMessage extends Message {
  String videoUrl;

  VideoMessage(this.videoUrl, timeStamp, senderName, senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory VideoMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return VideoMessage(data['videoUrl'], data['timeStamp'], data['senderName'],
        data['senderUsername']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['videoUrl'] = videoUrl;
    map['timeStamp'] = timeStamp;
    map['senderName'] = senderName;
    map['senderUsername'] = senderUsername;
    map['type'] = 2;
    return map;
  }
}

class FileMessage extends Message {
  String fileUrl;

  FileMessage(this.fileUrl, timeStamp, senderName, senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory FileMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return FileMessage(data['fileUrl'], data['timeStamp'], data['senderName'],
        data['senderUsername']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['fileUrl'] = fileUrl;
    map['timeStamp'] = timeStamp;
    map['senderName'] = senderName;
    map['senderUsername'] = senderUsername;
    map['type'] = 3;
    return map;
  }
}
