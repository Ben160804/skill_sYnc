import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> Register(String name, String email, String password) async {
    try {
      if (name.isEmpty) {
        print('Error: Name is empty during registration');
        throw Exception('Name cannot be empty');
      }
      if (email.isEmpty || password.isEmpty) {
        print('Error: Email or password is empty');
        throw Exception('Email and password cannot be empty');
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        print('User registered with UID: ${user.uid}, name: $name');
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw Exception('An error occurred during registration: $e');
    }
  }

  Future<User?> Login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during login: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Unexpected error during login: $e');
      throw Exception('An error occurred during sign in: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print('Fetched profile from Firestore: ${doc.data()}');
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      print('No profile exists for UID: $uid');
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      if (profile.name.isEmpty) {
        print('Warning: Name is empty in profile: ${profile.toJson()}');
      }
      print('Saving profile to Firestore: ${profile.toJson()}');
      await _firestore.collection('users').doc(profile.uid).set(
            profile.toJson(),
            SetOptions(merge: true),
          );
      print('Profile saved successfully for UID: ${profile.uid}');
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Error saving user profile: $e');
    }
  }

  Future<bool> isProfileExists(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        print('No document exists for UID: $uid');
        return false;
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      bool exists = data['bio'] != null;
      print('Profile exists check for UID: $uid - $exists');
      return exists;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }
}