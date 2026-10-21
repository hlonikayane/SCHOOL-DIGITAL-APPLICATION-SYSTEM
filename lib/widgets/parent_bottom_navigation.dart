import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/subjects_screen.dart';
import '../screens/application_status_screen.dart';
import '../screens/profile_screen.dart';

/// Screenshot-matched shared navigation bar for all parent portal pages.
class ParentBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const ParentBottomNavigation({super.key, required this.currentIndex});

  static const _labels = ['Home', 'Announcements', 'Subjects', 'Applications', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.campaign_outlined,
    Icons.menu_book_outlined,
    Icons.description_outlined,
    Icons.person_outline,
  ];
  static const _wine = Color(0xFF711D28);
  static const _ink = Color(0xFF34445B);
  static const _border = Color(0xFFCBD7E7);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: const Border(top: BorderSide(color: _border, width: 1)),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
          boxShadow: const [BoxShadow(color: Color(0x120F172A), blurRadius: 5, offset: Offset(0, -2))],
        ),
        child: Row(
          children: List.generate(_labels.length, (index) {
            final selected = index == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (selected) return;
                  final Widget page = switch (index) {
                    0 => const HomeScreen(),
                    1 => const AnnouncementsScreen(),
                    2 => const SubjectsScreen(),
                    3 => const ApplicationStatusScreen(),
                    _ => const ProfileScreen(),
                  };
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => page),
                    (route) => route.isFirst,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 108,
                      height: 3,
                      decoration: BoxDecoration(
                        color: selected ? _wine : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFF8EEEE) : Colors.white,
                        border: Border.all(color: selected ? _wine : _border, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(_icons[index], size: 25, color: selected ? _wine : _ink),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Text(
                        _labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.1,
                          color: selected ? _wine : _ink,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
