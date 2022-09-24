import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  late String userId;
  late Timestamp dateTime;
  late String comment;
  late String image;
  File? fileImage;
  //not for cloud
  late String commentId;
  late int likes_num;
  late int replays_num;
  late String myLikeId;
  late bool iLikeIt;
  late bool showReplays;
  List<String>? usersWhoLikeComment;

  CommentModel({
    required this.userId,
    required this.dateTime,
    required this.comment,
    this.fileImage,
    this.commentId = '',
    this.likes_num = 0,
    this.image = '',
    this.myLikeId = '',
    this.iLikeIt = false,
    this.replays_num = 0,
    this.showReplays = false,
    this.usersWhoLikeComment,
  });

  CommentModel.fromJson({
    required Map<String, dynamic> json,
    required String id,
    int? likes,
    int? replays,
    List<String>? usersWhoLikeComment,
  }) {
    userId = json['userId'];
    dateTime = json['dateTime'];
    comment = json['comment'];
    image = json['image'];
    commentId = id;
    likes_num = likes ?? 0;
    replays_num = replays ?? 0;
    myLikeId = json['myLikeId'];
    iLikeIt = json['myLikeId'] == '' ? false : true;
    showReplays = false;
    // ignore: prefer_initializing_formals
    this.usersWhoLikeComment = usersWhoLikeComment;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dateTime': dateTime,
      'comment': comment,
      'image': image,
      'myLikeId': myLikeId,
      'commentId': '',
    };
  }
}
