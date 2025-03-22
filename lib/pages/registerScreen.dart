import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
final FirebaseService _firebaseService = FirebaseService();
String? _email;
String? _password;
String? _name;
bool _obscureText = true;
bool _isLoading = false;

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill Sync',
          style: TextStyle(
            fontFamily: 'Roboto', // Modern font
            fontWeight: FontWeight.w700,
            color: Colors.white70,
            fontSize: 26, // Slightly larger for emphasis
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Middle-ground color
        elevation: 8.0,
        shadowColor: Colors.black45,
      ),
      body: Container(
        color: Colors.grey[100], // Minimalistic background color
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _titleWidget(),
                SizedBox(height: 32.0),
                _registerForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return Text(
      'Register',
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _nameField(),
          SizedBox(height: 20.0),
          _emailField(),
          SizedBox(height: 20.0),
          _passwordField(),
          SizedBox(height: 32.0),
          _registerButton(),
          SizedBox(height: 16.0),
          _noAccount(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        hintText: 'Name',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
      onSaved: (value) {
        _name = value;
        print('Name saved: $_name');
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null ||
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (value) => _email = value,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onSaved: (value) => _password = value,
    );
  }

  Widget _registerButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (_registerFormKey.currentState!.validate()) {
                _registerFormKey.currentState!.save();
                print('Registering with: name: $_name, email: $_email');
                setState(() => _isLoading = true);
                try {
                  User? user = await _firebaseService.Register(
                      _name!, _email!, _password!);
                  if (user != null) {
                    UserProfile initialProfile = UserProfile(
                      uid: user.uid,
                      name: _name!,
                      email: _email!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration successful!')),
                    );
                    Navigator.pushReplacementNamed(context, '/setup/bio',
                        arguments: initialProfile);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration failed')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Text(
              'Register',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Matching middle-ground color
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
      ),
    );
  }

  Widget _noAccount() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: Text(
        'Already have an account? Login',
        style: TextStyle(
          color: const Color.fromARGB(255, 13, 28, 68), // Matching the new theme
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}