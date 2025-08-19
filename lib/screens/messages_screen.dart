import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dating_app/services/auth_service.dart';
import 'package:flutter_dating_app/services/message_service.dart';
import 'package:flutter_dating_app/screens/chat_screen.dart';
import 'dart:io';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _messageService = MessageService();
  List<Map<String, dynamic>> _chatPreviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatPreviews();
  }

  Future<void> _loadChatPreviews() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    if (currentUser != null) {
      final chatPreviews = await _messageService.getChatPreviews(currentUser.id!);
      setState(() {
        _chatPreviews = chatPreviews;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_chatPreviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start chatting with your matches',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _chatPreviews.length,
      itemBuilder: (context, index) {
        final chatPreview = _chatPreviews[index];
        final userId = chatPreview['id'] as int;
        final name = chatPreview['name'] as String;
        final profileImagePath = chatPreview['profile_image_path'] as String?;
        final lastMessage = chatPreview['text'] as String;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(chatPreview['timestamp'] as int);
        final isRead = chatPreview['is_read'] == 1;
        final isFromCurrentUser = chatPreview['sender_id'] == Provider.of<AuthService>(context, listen: false).currentUser!.id;
        
        return ChatPreviewTile(
          userId: userId,
          name: name,
          profileImagePath: profileImagePath,
          lastMessage: lastMessage,
          timestamp: timestamp,
          isRead: isRead,
          isFromCurrentUser: isFromCurrentUser,
        );
      },
    );
  }
}

class ChatPreviewTile extends StatelessWidget {
  final int userId;
  final String name;
  final String? profileImagePath;
  final String lastMessage;
  final DateTime timestamp;
  final bool isRead;
  final bool isFromCurrentUser;
  
  const ChatPreviewTile({
    required this.userId,
    required this.name,
    this.profileImagePath,
    required this.lastMessage,
    required this.timestamp,
    required this.isRead,
    required this.isFromCurrentUser,
  });

  String _getTimeString() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(userId: userId, userName: name),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: profileImagePath != null
            ? FileImage(File(profileImagePath!))
            : AssetImage('assets/default_profile.png') as ImageProvider,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          if (isFromCurrentUser)
            Text(
              'You: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          Expanded(
            child: Text(
              lastMessage,
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 12,
                color: isRead ? Colors.grey : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _getTimeString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          if (!isRead && !isFromCurrentUser)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF4B91),
              ),
            ),
        ],
      ),
    );
  }
}
