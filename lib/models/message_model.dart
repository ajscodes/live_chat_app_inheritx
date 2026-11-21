import 'package:cloud_firestore/cloud_firestore.dart';

/// Message Model representing a chat message in Firestore.
/// Matches the /messages/{messageId} security rules.
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

  /// Convert to Map for saving to Firestore
  /// Note: Matches security rule constraints:
  /// - senderId must equal request.auth.uid
  /// - receiverId is string
  /// - message is string
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Create MessageModel from Firestore document snapshot
  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTimestamp;
    final timeVal = map['timestamp'];
    if (timeVal is Timestamp) {
      parsedTimestamp = timeVal.toDate();
    } else if (timeVal is DateTime) {
      parsedTimestamp = timeVal;
    } else {
      // Handles optimistic/pending local writes before server confirms timestamp
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
