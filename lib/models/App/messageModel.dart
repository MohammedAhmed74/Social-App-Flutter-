import 'dart:io';

class MessageModel {
  late String resiverId;
  late String senderId;
  late String dateTime;
  late String message;
  late String image;
  File? fileImage;

  MessageModel({
    required this.resiverId,
    required this.senderId,
    required this.dateTime,
    required this.message,
    this.fileImage,
    this.image = '',
  });

  MessageModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    resiverId = json['resiverId'];
    senderId = json['senderId'];
    dateTime = json['dateTime'];
    message = json['message'];
    image = json['image'];
  }

  Map<String, dynamic> toMap() {
    return {
      'resiverId': resiverId,
      'senderId': senderId,
      'dateTime': dateTime,
      'message': message,
      'image': image,
    };
  }
}
