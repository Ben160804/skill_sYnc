import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/models/request_model.dart';
import '/pages/addskilldialog.dart';
import '/pages/user_profile_tile.dart';

class MatchScreen extends StatefulWidget {
  final UserProfile initialProfile;

  MatchScreen({required this.initialProfile});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _currentIndex = 1; // 1 = Match (this screen)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentRequestId;
  List<String> _previousReturnedUsers = [];

  @override
  void initState() {
    super.initState();
    print('MatchScreen received profile: ${widget.initialProfile.toJson()}');
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          '/profile',
          arguments: widget.initialProfile,
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/chat', arguments: widget.initialProfile);
        break;
    }
  }

  Future<void> _findMatch() async {
    final requestData = await showDialog<Map<String, List<String>>>(
      context: context,
      builder: (context) => _MatchRequestDialog(),
    );

    if (requestData != null) {
      try {
        Request request = Request(
          id: '',
          userId: widget.initialProfile.uid,
          skillRequired: requestData['skillRequired']!,
          skillLevelRequired: requestData['skillLevelRequired']!,
          requesterName: widget.initialProfile.name ?? 'Unknown',
          timestamp: DateTime.now(),
          status: 'pending',
          returnedUsers: [],
        );

        DocumentReference docRef = await _firestore.collection('requests').add(request.toJson());
        setState(() {
          _currentRequestId = docRef.id;
          _previousReturnedUsers = [];
        });
        print('Request saved with ID: ${_currentRequestId}');
      } catch (e) {
        print('Error saving match request: $e');
      }
    }
  }

  Stream<DocumentSnapshot> _getRequestStream() {
    if (_currentRequestId == null) {
      return Stream.empty();
    }
    return _firestore.collection('requests').doc(_currentRequestId).snapshots();
  }

  void _checkReturnedUsersChanges(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      final currentReturnedUsers = List<String>.from(data['returnedUsers'] as List<dynamic>? ?? []);
      if (_previousReturnedUsers.isNotEmpty && _previousReturnedUsers != currentReturnedUsers) {
        print('Request $_currentRequestId: returnedUsers changed from $_previousReturnedUsers to $currentReturnedUsers');
      }
      _previousReturnedUsers = currentReturnedUsers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill Sync',
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  Text(
                    'Hello, ${widget.initialProfile.name ?? "User"}!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Click below to find your match',
                    style: TextStyle(fontSize: 18.0, color: Colors.black54),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _findMatch,
                    child: Text(
                      'Find Match',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 28, 68),
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      elevation: 4.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _getRequestStream(),
                builder: (context, snapshot) {
                  if (_currentRequestId == null) {
                    return Center(
                      child: Text(
                        'Matches will appear here.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text(
                        'Waiting for matches...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error occurred',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                      ),
                    );
                  }

                  final requestDoc = snapshot.data!;
                  if (!requestDoc.exists) {
                    return Center(
                      child: Text(
                        'Request not found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                      ),
                    );
                  }

                  final request = Request.fromJson(requestDoc.data() as Map<String, dynamic>, requestDoc.id);
                  _checkReturnedUsersChanges(requestDoc);
                  final returnedUsers = request.returnedUsers;

                  return returnedUsers.isEmpty
                      ? Center(
                          child: Text(
                            'No matches found yet',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                          ),
                        )
                      : ListView.builder(
                          itemCount: returnedUsers.length,
                          itemBuilder: (context, index) {
                            final userId = returnedUsers[index];
                            return FutureBuilder<DocumentSnapshot>(
                              future: _firestore.collection('users').doc(userId).get(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return SizedBox.shrink();
                                }
                                if (userSnapshot.hasError || !userSnapshot.data!.exists) {
                                  return ListTile(
                                    title: Text(
                                      'User $userId not found',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  );
                                }
                                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                final user = UserProfile.fromJson(userData);
                                return UserProfileTile(
                                  user: user,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/user_profile',
                                      arguments: {'user': user, 'requestId': request.id},
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                },
              ),
            ),
          ],
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

class _MatchRequestDialog extends StatefulWidget {
  @override
  __MatchRequestDialogState createState() => __MatchRequestDialogState();
}

class __MatchRequestDialogState extends State<_MatchRequestDialog> {
  final _numberController = TextEditingController();
  int _numberOfRequests = 0;
  List<String> _skills = [];
  List<String> _levels = [];

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _addSkill() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddSkillDialog(),
    );
    if (result != null) {
      setState(() {
        _skills.add(result['name']!);
        _levels.add(result['level']!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Match app theme
      title: Text(
        'Create Match Request',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.white70, // Adjusted for dark background
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _numberController,
              style: TextStyle(color: Colors.white70, fontSize: 16.0), // Adjusted for dark background
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Skills Needed',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800], // Slightly lighter than background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
              onChanged: (value) {
                setState(() {
                  _numberOfRequests = int.tryParse(value) ?? 0;
                  if (_skills.length > _numberOfRequests) {
                    _skills = _skills.sublist(0, _numberOfRequests);
                    _levels = _levels.sublist(0, _numberOfRequests);
                  }
                });
              },
            ),
            SizedBox(height: 16.0),
            Column(
              children: List.generate(
                _numberOfRequests,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _skills.length > index ? null : _addSkill,
                    child: Text(
                      _skills.length > index
                          ? '${_skills[index]} - ${_levels[index]}'
                          : 'Add Skill ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Consistent color
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Larger button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      elevation: 4.0, // Consistent elevation
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_numberController.text.isNotEmpty &&
                _skills.length == _numberOfRequests &&
                _skills.isNotEmpty) {
              Navigator.pop(context, {
                'skillRequired': _skills,
                'skillLevelRequired': _levels,
              });
            }
          },
          child: Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 28, 68),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            elevation: 4.0,
          ),
        ),
      ],
    );
  }
}