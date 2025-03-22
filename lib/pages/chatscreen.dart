import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/pages/chat_convo_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile userProfile;

  ChatScreen({required this.userProfile});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> _matchedUsers = [];
  int _currentIndex = 2; // Chat tab is selected

  @override
  void initState() {
    super.initState();
    _loadMatchedUsers();
  }

  Future<void> _loadMatchedUsers() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          List<String> matchedUserIds = List<String>.from(data['matchedUsers'] ?? []);

          List<Map<String, String>> matchedUsers = [];
          for (String uid in matchedUserIds) {
            DocumentSnapshot matchedUserDoc = await _firestore.collection('users').doc(uid).get();
            if (matchedUserDoc.exists) {
              final matchedData = matchedUserDoc.data() as Map<String, dynamic>;
              matchedUsers.add({
                'uid': uid,
                'name': matchedData['name'] ?? 'Unknown',
              });
            }
          }
          setState(() {
            _matchedUsers = matchedUsers;
          });
        }
      } catch (e) {
        print('Error loading matched users: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading matched users: $e')),
        );
      }
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/profile', arguments: widget.userProfile);
        break;
      case 1:
        Navigator.pushNamed(context, '/match', arguments: widget.userProfile);
        break;
      case 2:
        // Already on ChatScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _matchedUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 60.0,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'No matched users yet',
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
                  itemCount: _matchedUsers.length,
                  itemBuilder: (context, index) {
                    final matchedUser = _matchedUsers[index];
                    return Card(
                      elevation: 3.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatConversationScreen(
                                matchedUserId: matchedUser['uid']!,
                                matchedUserName: matchedUser['name']!,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22.0,
                                backgroundColor: const Color.fromARGB(255, 13, 28, 68),
                                child: Icon(Icons.person, size: 22.0, color: Colors.white70),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      matchedUser['name']!,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Tap to start chatting',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        selectedItemColor: Colors.white70,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Match'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}