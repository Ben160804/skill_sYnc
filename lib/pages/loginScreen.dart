import 'package:flutter/material.dart';
import '/services/firebase_service.dart';
import '/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
String? email;
String? password;
bool _obscureText = true;
bool _isLoading = false;
final FirebaseService _firebaseService = FirebaseService();

class _LoginScreenState extends State<LoginScreen> {
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
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Matching color
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
                _loginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return Text(
      'Login',
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          emailField(),
          SizedBox(height: 20.0),
          passwordField(),
          SizedBox(height: 32.0),
          _loginButton(),
          SizedBox(height: 16.0),
          _noAccount(),
        ],
      ),
    );
  }

  Widget emailField() {
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
      onSaved: (value) => email = value,
    );
  }

  Widget passwordField() {
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
      onSaved: (value) => password = value,
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (_loginFormKey.currentState!.validate()) {
                _loginFormKey.currentState!.save();
                setState(() => _isLoading = true);
                try {
                  User? user = await _firebaseService.Login(email!, password!);
                  if (user != null) {
                    bool exists =
                        await _firebaseService.isProfileExists(user.uid);
                    if (exists) {
                      UserProfile? profile =
                          await _firebaseService.getUserProfile(user.uid);
                      Navigator.pushReplacementNamed(context, '/profile',
                          arguments: profile);
                    } else {
                      UserProfile initialProfile = UserProfile(
                        uid: user.uid,
                        name: user.displayName ?? '',
                        email: user.email ?? '',
                      );
                      Navigator.pushReplacementNamed(context, '/setup/bio',
                          arguments: initialProfile);
                    }
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
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Matching color
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
      onPressed: () => Navigator.pushNamed(context, '/register'),
      child: Text(
        'Don\'t have an account? Register',
        style: TextStyle(
          color: const Color.fromARGB(255, 13, 28, 68), // Matching color
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}