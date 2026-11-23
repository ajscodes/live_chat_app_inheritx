import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSending = false;

  bool get isSending => _isSending;

  Stream<List<UserModel>> getUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('messages')
        .where(
          Filter.or(
            Filter.and(
              Filter('senderId', isEqualTo: currentUserId),
              Filter('receiverId', isEqualTo: otherUserId),
            ),
            Filter.and(
              Filter('senderId', isEqualTo: otherUserId),
              Filter('receiverId', isEqualTo: currentUserId),
            ),
          ),
        )
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();

          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<bool> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    final text = message.trim();

    if (currentUserId == null || text.isEmpty) return false;

    _isSending = true;
    notifyListeners();

    try {
      await _firestore.collection('messages').add({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> updateMessage({
    required String messageId,
    required String newMessage,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    final text = newMessage.trim();

    if (currentUserId == null || messageId.isEmpty || text.isEmpty) {
      return false;
    }

    try {
      await _firestore.collection('messages').doc(messageId).update({
        'message': text,
      });
      return true;
    } catch (e) {
      print('Error updating message: $e');
      return false;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || messageId.isEmpty) return false;

    try {
      await _firestore.collection('messages').doc(messageId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }
}
