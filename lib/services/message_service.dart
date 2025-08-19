import 'package:flutter_dating_app/db/database_helper.dart';
import 'package:flutter_dating_app/models/message.dart';

class MessageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Send a message
  Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String text,
  }) async {
    try {
      Message message = Message(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
      );
      
      await _dbHelper.insertMessage(message);
      return true;
    } catch (e) {
      print('Send message error: $e');
      return false;
    }
  }

  // Get messages for a chat
  Future<List<Message>> getMessages(int userId, int otherUserId) async {
    return await _dbHelper.getMessagesForChat(userId, otherUserId);
  }

  // Get chat previews for the messages screen
  Future<List<Map<String, dynamic>>> getChatPreviews(int userId) async {
    return await _dbHelper.getChatPreviews(userId);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int senderId, int receiverId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'messages',
        {'is_read': 1},
        where: 'sender_id = ? AND receiver_id = ? AND is_read = 0',
        whereArgs: [senderId, receiverId],
      );
    } catch (e) {
      print('Mark messages as read error: $e');
    }
  }
}
