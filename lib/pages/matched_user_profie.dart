import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/models/matchrequest_model.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfile user;
  final String? requestId;

  const UserProfileScreen({required this.user, this.requestId});

  Future<void> _sendMatchRequest(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to send a request')),
      );
      return;
    }

    if (currentUser.uid == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot send a request to yourself')),
      );
      return;
    }

    try {
      DocumentSnapshot senderDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String requesterName = senderDoc.exists
          ? (senderDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
          : 'Unknown';

      String matchRequestId = 'matchrequest_${currentUser.uid}_${user.uid}';
      MatchRequest matchRequest = MatchRequest(
        id: matchRequestId,
        requestId: requestId ?? 'no-request-id',
        requesterId: currentUser.uid,
        targetUserId: user.uid,
        requesterName: requesterName,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('match_requests')
          .doc(matchRequestId)
          .set(matchRequest.toJson());

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('match_requests')
          .doc(matchRequestId)
          .set(matchRequest.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match request sent to ${user.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${user.name ?? "User"}\'s Profile',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        elevation: 6.0,
        shadowColor: Colors.black45.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white70),
            tooltip: 'Send Match Request',
            onPressed: () => _sendMatchRequest(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
                        child: const Icon(
                          Icons.person,
                          size: 40.0,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    _buildProfileField(
                      label: 'Name',
                      value: user.name ?? 'Not set',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12.0),
                    _buildProfileField(
                      label: 'Email',
                      value: user.email ?? 'Not set',
                      icon: Icons.email_outlined,
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildProfileField(
                        label: 'Bio',
                        value: user.bio!,
                        icon: Icons.description_outlined,
                      ),
                    ],
                    if (user.address != null && user.address!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildProfileField(
                        label: 'Address',
                        value: user.address!,
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                    if (user.phone != null && user.phone!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildProfileField(
                        label: 'Phone',
                        value: user.phone!,
                        icon: Icons.phone_outlined,
                      ),
                    ],
                    const SizedBox(height: 24.0),
                    Text(
                      'Skills',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    user.skills.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'No skills added yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.0,
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: user.skills.map((skill) {
                              return Chip(
                                label: Text(
                                  '${skill['name']} - ${skill['level']}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12.0,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 1.0,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide.none,
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Links',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    user.links.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'No links added yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.0,
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: user.links.map((link) {
                              return Chip(
                                label: Text(
                                  '${link['platform']} - ${link['url']}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12.0,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 1.0,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide.none,
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color.fromARGB(255, 13, 28, 68),
          size: 20.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}