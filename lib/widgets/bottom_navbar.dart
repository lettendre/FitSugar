import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/solar_home_outline.svg',
            width: 24,
            height: 24,
            color: currentIndex == 0 ? Colors.pink : Colors.black,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/solar_search_outline.svg',
            width: 24,
            height: 24,
            color: currentIndex == 1 ? Colors.pink : Colors.black,
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/solar_history_outline.svg',
            width: 24,
            height: 24,
            color: currentIndex == 2 ? Colors.pink : Colors.black,
          ),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/solar_user_outline.svg',
            width: 24,
            height: 24,
            color: currentIndex == 3 ? Colors.pink : Colors.black,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}