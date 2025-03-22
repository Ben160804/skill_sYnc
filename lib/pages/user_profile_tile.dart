import 'package:flutter/material.dart';
import '/models/user_model.dart';

class UserProfileTile extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;

  const UserProfileTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white, // Light background to contrast with app's grey[100]
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: const Color.fromARGB(255, 13, 28, 68), // Theme color
                child: const Icon(
                  Icons.person,
                  size: 30.0,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 13, 28, 68), // Theme color for text
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54, // Subtle contrast on white card
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromARGB(255, 13, 28, 68), // Theme color
              ),
            ],
          ),
        ),
      ),
    );
  }
}