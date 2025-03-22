import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '../addskilldialog.dart';

class SkillsSetupScreen extends StatefulWidget {
  final UserProfile initialProfile;

  SkillsSetupScreen({required this.initialProfile});

  @override
  _SkillsSetupScreenState createState() => _SkillsSetupScreenState();
}

class _SkillsSetupScreenState extends State<SkillsSetupScreen> {
  List<Map<String, String>> _skills = [];

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.initialProfile.skills);
    print('Initial profile in SkillsSetupScreen: ${widget.initialProfile.toJson()}');
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add your skills',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.0),
              _skills.isEmpty
                  ? Text(
                      'No skills added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.0,
                      ),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _skills
                          .map((skill) => Chip(
                                label: Text(
                                  '${skill['name']} - ${skill['level']}',
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
                                    setState(() => _skills.remove(skill)),
                              ))
                          .toList(),
                    ),
              SizedBox(height: 16.0),
              _addSkillButton(),
              Spacer(), // Pushes buttons to the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _skipButton(),
                  _nextButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addSkillButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => AddSkillDialog(),
        );
        if (result != null) {
          setState(() => _skills.add(result));
        }
      },
      child: Text(
        'Add Skill',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      onPressed: () => Navigator.pushNamed(context, '/setup/links',
          arguments: widget.initialProfile),
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

  Widget _nextButton() {
    return ElevatedButton(
      onPressed: () {
        UserProfile updatedProfile = UserProfile(
          uid: widget.initialProfile.uid,
          name: widget.initialProfile.name,
          email: widget.initialProfile.email,
          bio: widget.initialProfile.bio,
          address: widget.initialProfile.address,
          phone: widget.initialProfile.phone,
          skills: _skills,
        );
        print('Passing to LinksSetupScreen: ${updatedProfile.toJson()}');
        Navigator.pushNamed(context, '/setup/links', arguments: updatedProfile);
      },
      child: Text(
        'Next',
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