import 'package:flutter/material.dart';
import '/models/user_model.dart';

class AddressSetupScreen extends StatefulWidget {
  final UserProfile initialProfile;

  AddressSetupScreen({required this.initialProfile});

  @override
  _AddressSetupScreenState createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('Initial profile in AddressSetupScreen: ${widget.initialProfile.toJson()}');
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Where are you located?',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.0),
                _addressField(),
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
      ),
    );
  }

  Widget _addressField() {
    return TextFormField(
      controller: _addressController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        hintText: 'e.g., 123 Main St, City',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      maxLines: 2, // Increased for a slightly bigger field
      validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
    );
  }

  Widget _skipButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/setup/phone',
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
        if (_formKey.currentState!.validate()) {
          UserProfile updatedProfile = UserProfile(
            uid: widget.initialProfile.uid,
            name: widget.initialProfile.name,
            email: widget.initialProfile.email,
            bio: widget.initialProfile.bio,
            address: _addressController.text,
          );
          print('Passing to PhoneSetupScreen: ${updatedProfile.toJson()}');
          Navigator.pushNamed(context, '/setup/phone',
              arguments: updatedProfile);
        }
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