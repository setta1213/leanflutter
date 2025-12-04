import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final firstname = userData?["firstname"] ?? "-";
    final lastname = userData?["lastname"] ?? "-";
    final role = userData?["role"] ?? "-";
    final img = userData?["img"];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // รูปโปรไฟล์
          CircleAvatar(
            radius: 45,
            backgroundImage: img != null
                ? NetworkImage(img)
                : const AssetImage("assets/images/btu.png") as ImageProvider,
          ),
          const SizedBox(height: 16),

          Text(
            "$firstname $lastname",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Role: $role",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
