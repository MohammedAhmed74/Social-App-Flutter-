import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiverModel {
  late DateTime? lastSeen;
  late bool? isOnline;
  late Timestamp? seenTime;
  ReceiverModel.fromJson(Map<String, dynamic>? json) {
    seenTime = json?['lastSeen'];
    isOnline = json?['isOnline'];
    lastSeen = seenTime!.toDate();
  }
  ReceiverModel(
      {required this.isOnline, required this.lastSeen, required this.seenTime});
}
