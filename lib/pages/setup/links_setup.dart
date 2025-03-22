import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '../addlinkdialog.dart';
import '/services/firebase_service.dart';

class LinksSetupScreen extends StatefulWidget {
  final UserProfile initialProfile;

  LinksSetupScreen({required this.initialProfile});

  @override
  _LinksSetupScreenState createState() => _LinksSetupScreenState();
}

class _LinksSetupScreenState extends State<LinksSetupScreen> {
  List<Map<String, String>> _links = [];
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _links = List.from(widget.initialProfile.links);
    print('Initial profile in LinksSetupScreen: ${widget.initialProfile.toJson()}');
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
        child: _isLoading
            ? Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: const Color.fromARGB(255, 13, 28, 68),
                    strokeWidth: 4.0,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add your links',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 24.0),
                    _links.isEmpty
                        ? Text(
                            'No links added yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.0,
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _links
                                .map((link) => Chip(
                                      label: Text(
                                        link['name'] ?? '',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        side: BorderSide.none,
                                      ),
                                      deleteIcon: Icon(
                                        Icons.close,
                                        size: 18.0,
                                        color: Colors.grey[600],
                                      ),
                                      onDeleted: () =>
                                          setState(() => _links.remove(link)),
                                    ))
                                .toList(),
                          ),
                    SizedBox(height: 16.0),
                    _addLinkButton(),
                    Spacer(), // Pushes buttons to the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _skipButton(),
                        _finishButton(),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _addLinkButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.add, color: Colors.white),
      label: Text(
        'Add Link',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
      ),
    );
  }

  Widget _skipButton() {
    return TextButton(
      onPressed: () async {
        setState(() => _isLoading = true);
        await _firebaseService.saveUserProfile(widget.initialProfile);
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/profile',
            arguments: widget.initialProfile);
      },
      child: Text(
        'Skip',
        style: TextStyle(
          color: const Color.fromARGB(255, 13, 28, 68),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _finishButton() {
    return ElevatedButton(
      onPressed: () async {
        setState(() => _isLoading = true);
        UserProfile updatedProfile = UserProfile(
          uid: widget.initialProfile.uid,
          name: widget.initialProfile.name,
          email: widget.initialProfile.email,
          bio: widget.initialProfile.bio,
          address: widget.initialProfile.address,
          phone: widget.initialProfile.phone,
          skills: widget.initialProfile.skills,
          links: _links,
        );
        await _firebaseService.saveUserProfile(updatedProfile);
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/profile',
            arguments: updatedProfile);
      },
      child: Text(
        'Finish',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
      ),
    );
  }
}