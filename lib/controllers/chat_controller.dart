import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

/// ChatController manages real-time messaging and user list retrieval.
/// Extends ChangeNotifier to provide reactive state across the app.
class ChatController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSending = false;
  String? _errorMessage;

  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  /// Real-time stream of all users except the currently logged-in user.
  /// Firestore rule: allow read: if request.auth != null;
  Stream<List<UserModel>> getUsersStream() {
    final currentUserId = _auth.currentUser?.uid;

    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.uid != currentUserId)
          .toList();
    });
  }

  /// Real-time stream of messages between the current user and the peer.
  /// Complies strictly with Firestore security rule:
  /// allow read: if request.auth != null
  ///   && (request.auth.uid == resource.data.senderId
  ///   || request.auth.uid == resource.data.receiverId);
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    // Query messages where:
    // (senderId == currentUserId && receiverId == otherUserId) OR
    // (senderId == otherUserId && receiverId == currentUserId)
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

      // Sort chronologically by timestamp in-memory (no composite index required)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  /// Send a new message to the peer.
  /// Complies strictly with Firestore create security rule:
  /// allow create: if request.auth != null
  ///   && request.resource.data.senderId == request.auth.uid
  ///   && request.resource.data.receiverId is string
  ///   && request.resource.data.message is string;
  Future<bool> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    final text = message.trim();

    if (currentUserId == null || text.isEmpty) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messageData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('messages').add(messageData);

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
