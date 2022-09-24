import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  late String uId;
  late String name;
  late Timestamp time;
  late String text;
  late String postImage;
  //not for cloud
  late String postId;
  late int likes_num;
  late int comments_num;
  late String myLikeId;
  late bool iLikeIt;
  late bool saved;
  late List<String>? userWhoLikeIds;

  PostModel({
    required this.uId,
    required this.name,
    required this.time,
    this.text = '',
    this.postImage = '',
    this.myLikeId = '',
    this.saved = false,
    this.userWhoLikeIds,
  });

  PostModel.fromJson({
    required Map<String, dynamic> json,
    required String id,
    int? likes,
    int? comments,
    List<String>? usersWhoLike,
  }) {
    uId = json['uId'];
    time = json['time'];
    text = json['text'];
    name = '';
    postImage = json['postImage'];
    postId = id;
    likes_num = likes ?? 0;
    comments_num = comments ?? 0;
    myLikeId = json['myLikeId'];
    iLikeIt = json['myLikeId'] == '' ? false : true;
    saved = json['saved'];
    userWhoLikeIds = usersWhoLike;
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'time': time,
      'text': text,
      'postImage': postImage,
      'myLikeId': myLikeId,
      'saved': saved,
    };
  }
}
