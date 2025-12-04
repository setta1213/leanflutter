import 'package:flutter/material.dart';
import 'package:leanflutter/src/pages/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Function(int) onMenuTap;
  const HomeDrawer({
    super.key,
    required this.userData,
    required this.onMenuTap,
  });

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstname = userData?["firstname"] ?? "";
    final lastname = userData?["lastname"] ?? "";
    final role = userData?["role"] ?? "";
    final img = userData?["img"];

    return Drawer(
      width: 280,
      backgroundColor: Colors.black,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Avatar with Status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: img != null
                          ? NetworkImage(img)
                          : const AssetImage("assets/images/btu.png")
                              as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        "$firstname $lastname",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role,
                        style: TextStyle(
                          color: const Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: "Home",
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: "Profile",
                    onTap: () {
                      onMenuTap(3);
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.work_rounded,
                    title: "My Works",
                    badge: 5,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_rounded,
                    title: "Notifications",
                    badge: 12,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help_rounded,
                    title: "Help Center",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_rounded,
                    title: "Privacy Policy",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Logout Button
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.05),
            ),
            child: ListTile(
              onTap: () => _logout(context),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Function() onTap,
    bool isActive = false,
    int? badge,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFFD700).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white70,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFFFD700) : Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        minLeadingWidth: 0,
      ),
    );
  }
}