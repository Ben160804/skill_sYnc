import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/chat_message_model.dart';

class ChatConversationScreen extends StatefulWidget {
  final String matchedUserId;
  final String matchedUserName;

  ChatConversationScreen({required this.matchedUserId, required this.matchedUserName});

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getChatId() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return '';
    String uid1 = currentUser.uid;
    String uid2 = widget.matchedUserId;
    return uid1.compareTo(uid2) < 0 ? '${uid1}_${uid2}' : '${uid2}_${uid1}';
  }

  Future<void> _loadMessages() async {
    String chatId = _getChatId();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _messages = snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || _messageController.text.trim().isEmpty) return;

    String chatId = _getChatId();
    ChatMessage message = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser.uid,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      DocumentReference docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson());
      await docRef.update({'id': docRef.id}); // Optional: Set the ID field
      _messageController.clear();
      _loadMessages(); // Refresh messages
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _updateMessage(String messageId, String newText) async {
    String chatId = _getChatId();
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'text': newText});
      _loadMessages(); // Refresh messages
    } catch (e) {
      print('Error updating message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating message: $e')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    String chatId = _getChatId();
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
      _loadMessages(); // Refresh messages
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  void _showEditDialog(ChatMessage message) {
    TextEditingController editController = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text('Edit Message', style: TextStyle(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Enter new message',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              _updateMessage(message.id, editController.text.trim());
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: const Color.fromARGB(255, 13, 28, 68))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.matchedUserName}',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            color: Colors.white70,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        elevation: 8.0,
        shadowColor: Colors.black45,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 60.0,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true, // Latest messages at the bottom
                      padding: EdgeInsets.all(16.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderId == currentUser?.uid;
                        return GestureDetector(
                          onLongPress: isMe
                              ? () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                    ),
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.edit, color: Colors.grey[600]),
                                          title: Text('Edit'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showEditDialog(message);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text('Delete'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _deleteMessage(message.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment:
                                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Card(
                                    elevation: 2.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    color: isMe
                                        ? const Color.fromARGB(255, 13, 28, 68)
                                        : Colors.grey[300],
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.text,
                                            style: TextStyle(
                                              color: isMe ? Colors.white : Colors.black87,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            message.timestamp.toString().substring(0, 16),
                                            style: TextStyle(
                                              color: isMe ? Colors.white70 : Colors.grey[600],
                                              fontSize: 12.0,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: const Color.fromARGB(255, 13, 28, 68),
                    mini: true,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}