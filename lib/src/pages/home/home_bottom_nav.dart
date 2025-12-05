import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color.fromARGB(255, 20, 223, 20).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: (MediaQuery.of(context).size.width / 4) * currentIndex,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Navigation Items
          Row(
            children: [
              _buildNavItem(
                icon: Icons.calendar_month,
                activeIcon: Icons.calendar_month,
                label: "ตารางเข้างาน",
                index: 0,
                badge: null,
              ),
              _buildNavItem(
                icon: Icons.format_list_numbered_rounded,
                activeIcon: Icons.format_list_numbered_rounded,
                label: "รายงาน",
                index: 1,
                badge: null,
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: "แจ้งเตือน",
                index: 2,
                badge: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: "โปรไฟล์",
                index: 3,
                badge: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    int? badge,
  }) {
    bool isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 80,
          color: const Color.fromARGB(0, 138, 124, 124),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withOpacity(0.3),
                                const Color(0xFFFFB300).withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isActive ? activeIcon : icon,
                        key: ValueKey(isActive),
                        color: isActive
                            ? const Color(0xFFFFD700)
                            : Colors.white54,
                        size: 24,
                      ),
                    ),
                  ),
                  if (badge != null && badge > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive ? const Color(0xFFFFD700) : Colors.white54,
                  fontSize: isActive ? 13 : 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: isActive ? 0.5 : 0,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
