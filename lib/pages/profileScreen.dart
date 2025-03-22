import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/models/matchrequest_model.dart';
import '../pages/addskilldialog.dart';
import '../pages/addlinkdialog.dart';
import '/pages/matched_user_profie.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  ProfileScreen({required this.userProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String? _name;
  String? _email;
  List<Map<String, String>> _skills = [];
  List<Map<String, String>> _links = [];
  List<MatchRequest> _pendingRequests = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _name = widget.userProfile.name;
    _email = widget.userProfile.email;
    _bioController = TextEditingController(text: widget.userProfile.bio ?? '');
    _addressController = TextEditingController(text: widget.userProfile.address ?? '');
    _phoneController = TextEditingController(text: widget.userProfile.phone ?? '');
    _skills = List.from(widget.userProfile.skills);
    _links = List.from(widget.userProfile.links);
    _loadProfileData();
    _loadPendingRequests();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? _name;
            _email = data['email'] ?? _email;
            _bioController.text = data['bio'] ?? _bioController.text;
            _addressController.text = data['address'] ?? _addressController.text;
            _phoneController.text = data['phone'] ?? _phoneController.text;
            _skills = (data['skills'] as List<dynamic>? ?? []).map((e) => Map<String, String>.from(e as Map)).toList();
            _links = (data['links'] as List<dynamic>? ?? []).map((e) => Map<String, String>.from(e as Map)).toList();
          });
        }
      } catch (e) {
        print('Error loading profile data: $e');
      }
    }
  }

  Future<void> _loadPendingRequests() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('match_requests')
            .where('status', isEqualTo: 'pending')
            .where('targetUserId', isEqualTo: user.uid)
            .get();
        setState(() {
          _pendingRequests = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Loaded request: $data');
            return MatchRequest.fromJson(data, doc.id);
          }).toList();
        });
      } catch (e) {
        print('Error loading pending requests: $e');
      }
    }
  }

  Future<void> _handleRequest(String requestId, String action) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      MatchRequest request = _pendingRequests.firstWhere((r) => r.id == requestId);
      DocumentReference senderRef = _firestore
          .collection('users')
          .doc(request.requesterId)
          .collection('match_requests')
          .doc(requestId);
      DocumentReference receiverRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('match_requests')
          .doc(requestId);

      if (action == 'accept') {
        await senderRef.update({'status': 'accepted'});
        await receiverRef.update({'status': 'accepted'});

        await _firestore.collection('users').doc(user.uid).update({
          'matchedUsers': FieldValue.arrayUnion([request.requesterId])
        });
        await _firestore.collection('users').doc(request.requesterId).update({
          'matchedUsers': FieldValue.arrayUnion([user.uid])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request accepted')),
        );
      } else {
        await senderRef.update({'status': 'rejected'});
        await receiverRef.update({'status': 'rejected'});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request rejected')),
        );
      }
      _loadPendingRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling request: $e')),
      );
    }
  }

  void _showRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: Colors.grey[100],
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: const Color.fromARGB(255, 13, 28, 68)),
            SizedBox(width: 8.0),
            Text(
              'Pending Requests',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: _pendingRequests.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No pending requests',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _pendingRequests.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                           
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      DocumentSnapshot requesterDoc = await _firestore
                                          .collection('users')
                                          .doc(request.requesterId)
                                          .get();
                                      if (requesterDoc.exists) {
                                        UserProfile requesterProfile = UserProfile.fromJson(
                                            requesterDoc.data() as Map<String, dynamic>);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserProfileScreen(
                                              user: requesterProfile,
                                              requestId: request.requestId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      request.requesterName,
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 13, 28, 68),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Sent: ${request.timestamp.toString().substring(0, 16)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check, color: Colors.green, size: 20.0),
                                  ),
                                  onPressed: () {
                                    _handleRequest(request.id, 'accept');
                                    Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close, color: Colors.red, size: 20.0),
                                  ),
                                  onPressed: () {
                                    _handleRequest(request.id, 'reject');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: const Color.fromARGB(255, 13, 28, 68),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _saveProfileData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        UserProfile updatedProfile = UserProfile(
          uid: user.uid,
          name: _name ?? '',
          email: _email ?? '',
          bio: _bioController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          skills: _skills,
          links: _links,
          matchedUsers: widget.userProfile.matchedUsers,
        );
        await _firestore.collection('users').doc(user.uid).set(updatedProfile.toJson(), SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    UserProfile updatedProfile = UserProfile(
      uid: widget.userProfile.uid,
      name: _name ?? widget.userProfile.name,
      email: _email ?? widget.userProfile.email,
      bio: _bioController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      skills: _skills,
      links: _links,
      matchedUsers: widget.userProfile.matchedUsers,
    );
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/match', arguments: updatedProfile);
        break;
      case 2:
        Navigator.pushNamed(context, '/chat', arguments: updatedProfile);
        break;
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white70,
                  size: 28.0,
                ),
                tooltip: 'Pending Requests',
                onPressed: _showRequestsDialog,
              ),
              if (_pendingRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Center(
                      child: Text(
                        _pendingRequests.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Logout',
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50.0, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 24.0),
                _nameField(),
                SizedBox(height: 16.0),
                _emailField(),
                SizedBox(height: 16.0),
                _bioField(),
                SizedBox(height: 16.0),
                _addressField(),
                SizedBox(height: 16.0),
                _phoneField(),
                SizedBox(height: 24.0),
                _skillsSection(),
                SizedBox(height: 24.0),
                _linksSection(),
                SizedBox(height: 32.0),
                _saveButton(),
              ],
            ),
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

  Widget _nameField() {
    return TextField(
      controller: TextEditingController(text: _name ?? 'Not set'),
      enabled: false,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Name',
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: TextEditingController(text: _email ?? 'Not set'),
      enabled: false,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  Widget _bioField() {
    return TextField(
      controller: _bioController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Bio',
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      maxLines: 3,
    );
  }

  Widget _addressField() {
    return TextField(
      controller: _addressController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Address',
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      maxLines: 2,
    );
  }

  Widget _phoneField() {
    return TextField(
      controller: _phoneController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Phone',
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _skillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.0),
        _skills.isEmpty
            ? Text(
                'No skills added yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
              )
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _skills
                    .map(
                      (skill) => Chip(
                        label: Text(
                          '${skill['name']} - ${skill['level']}',
                          style: TextStyle(color: Colors.black87, fontSize: 14.0),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide.none,
                        ),
                        deleteIcon: Icon(Icons.close, size: 18.0, color: Colors.grey[600]),
                        onDeleted: () => setState(() => _skills.remove(skill)),
                      ),
                    )
                    .toList(),
              ),
        SizedBox(height: 8.0),
        ElevatedButton.icon(
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Skill',
            style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 28, 68),
            padding: EdgeInsets.symmetric(vertical: 14.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            elevation: 4.0,
          ),
          onPressed: () async {
            final result = await showDialog<Map<String, String>>(
              context: context,
              builder: (context) => AddSkillDialog(),
            );
            if (result != null) {
              setState(() => _skills.add(result));
            }
          },
        ),
      ],
    );
  }

  Widget _linksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Links',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.0),
        _links.isEmpty
            ? Text(
                'No links added yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
              )
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _links
                    .map(
                      (link) => Chip(
                        label: Text(
                          link['name'] ?? '',
                          style: TextStyle(color: Colors.black87, fontSize: 14.0),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide.none,
                        ),
                        deleteIcon: Icon(Icons.close, size: 18.0, color: Colors.grey[600]),
                        onDeleted: () => setState(() => _links.remove(link)),
                      ),
                    )
                    .toList(),
              ),
        SizedBox(height: 8.0),
        ElevatedButton.icon(
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Link',
            style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 28, 68),
            padding: EdgeInsets.symmetric(vertical: 14.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            elevation: 4.0,
          ),
          onPressed: () async {
            final result = await showDialog<Map<String, String>>(
              context: context,
              builder: (context) => AddLinkDialog(),
            );
            if (result != null) {
              setState(() => _links.add(result));
            }
          },
        ),
      ],
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _saveProfileData,
      child: Text(
        'Save Profile',
        style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4.0,
      ),
    );
  }
}