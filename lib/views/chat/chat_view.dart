import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../utils/string_constants.dart';
import 'widgets/chat_message.dart';

class ChatView extends StatefulWidget {
  final UserModel receiver;

  const ChatView({super.key, required this.receiver});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatController = Provider.of<ChatController>(context, listen: false);
    if (chatController.isSending) return;

    _messageController.clear();

    final sent = await chatController.sendMessage(
      receiverId: widget.receiver.uid,
      message: text,
    );

    if (!mounted) return;

    if (sent) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      _messageController.text = text; // Restore text so user doesn't lose it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showMessageOptions(MessageModel message, bool isCurrentUser) {
    if (!isCurrentUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ChatViewConstants.actionOnlyOwnMessage),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
              title: const Text(ChatViewConstants.editMessage),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text(
                ChatViewConstants.deleteMessageTitle,
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(MessageModel message) {
    final editController = TextEditingController(text: message.message);
    editController.selection = TextSelection.fromPosition(
      TextPosition(offset: editController.text.length),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ChatViewConstants.editMessageTitle),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: ChatViewConstants.typeMessage,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(ChatViewConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isEmpty) return;

              if (newText == message.message.trim()) {
                Navigator.pop(ctx);
                return;
              }

              Navigator.pop(ctx);
              final chatController =
                  Provider.of<ChatController>(context, listen: false);
              final success = await chatController.updateMessage(
                messageId: message.id,
                newMessage: newText,
              );

              if (!mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(ChatViewConstants.updateMessageFailed),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text(ChatViewConstants.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MessageModel message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ChatViewConstants.deleteMessageTitle),
        content: const Text(ChatViewConstants.deleteMessageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(ChatViewConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final chatController =
                  Provider.of<ChatController>(context, listen: false);
              final success = await chatController.deleteMessage(message.id);

              if (!mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(ChatViewConstants.deleteMessageFailed),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              ChatViewConstants.delete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthController>(context, listen: false).currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.receiver.name.isNotEmpty
                    ? widget.receiver.name[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.receiver.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.receiver.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: Provider.of<ChatController>(context, listen: false)
                  .getMessagesStream(widget.receiver.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '${ChatViewConstants.messageError}: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 64,
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ChatViewConstants.noMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ChatViewConstants.sayHello} ${widget.receiver.name}!',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == currentUserId;

                    return ChatMessage(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onLongPress: () => _showMessageOptions(message, isCurrentUser),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: ChatViewConstants.typeMessage,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
