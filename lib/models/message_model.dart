import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTimestamp;
    final timeVal = map['timestamp'];
    if (timeVal is Timestamp) {
      parsedTimestamp = timeVal.toDate();
    } else if (timeVal is DateTime) {
      parsedTimestamp = timeVal;
    } else {
      parsedTimestamp = DateTime.now();
    }

    return MessageModel(
      id: docId,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      timestamp: parsedTimestamp,
    );
  }
}
