import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live_chat_app_inheritx/utils/string_constants.dart';

import '../../../models/message_model.dart';

class ChatMessage extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat(ChatViewConstants.messageDateFormate)
        .format(message.timestamp);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onLongPress: onLongPress,
          onSecondaryTap: onLongPress,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? theme.colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isCurrentUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isCurrentUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, size: 14, color: Colors.white70),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
