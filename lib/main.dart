import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sharebill/pages/loginScreen.dart';
import 'package:sharebill/pages/registerScreen.dart';
import 'package:sharebill/pages/profileScreen.dart';
import 'package:sharebill/pages/setup/bio_setup.dart';
import 'package:sharebill/pages/setup/address_setup.dart';
import 'package:sharebill/pages/setup/phone_setup.dart';
import 'package:sharebill/pages/setup/skill_setup.dart';
import 'package:sharebill/pages/setup/links_setup.dart';
import 'package:sharebill/models/user_model.dart';
import '/firebase_options.dart';
import '/pages/match_screen.dart';
import '/pages/chatscreen.dart';
import '/pages/matched_user_profie.dart';
import '/pages/chat_convo_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Sync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/register',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(
              userProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
        '/setup/bio': (context) => BioSetupScreen(
              initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
        '/setup/address': (context) => AddressSetupScreen(
              initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
        '/setup/phone': (context) => PhoneSetupScreen(
              initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
        '/setup/skills': (context) => SkillsSetupScreen(
              initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
        '/setup/links': (context) => LinksSetupScreen(
              initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
            ),
      '/match': (context) => MatchScreen(
        initialProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
      ), // Placeholder
        '/chat': (context) => ChatScreen(
            userProfile: ModalRoute.of(context)!.settings.arguments as UserProfile,
          ), 
        '/user_profile': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  return UserProfileScreen(
    user: args['user'] as UserProfile,
    requestId: args['requestId'] as String?,
  );},
  '/chat_conversation': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return ChatConversationScreen(
          matchedUserId: args['matchedUserId']!,
          matchedUserName: args['matchedUserName']!,
        );
      },
      },
    );
  }
}

// Placeholder screens

