import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/user_model.dart';
import '../../utils/string_constants.dart';
import '../chat/chat_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AlertDialogueConstants.logOut),
        content: const Text(AlertDialogueConstants.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AlertDialogueConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authController.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(AlertDialogueConstants.logOut, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final chatController = Provider.of<ChatController>(context);
    final currentUser = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HomeViewConstants.homeViewAppBarTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (currentUser != null)
              Text(
                currentUser.displayName ?? currentUser.email ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, authController),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: chatController.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${HomeViewConstants.homeViewErrorLoadingUsers} ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 72,
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      HomeViewConstants.homeViewNoUsersHeading,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      HomeViewConstants.homeViewNoUsersSubHeading,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(
              endIndent: 15,
              indent: 15,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : HomeViewConstants.homeViewDefaultUserInitial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatView(receiver: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
