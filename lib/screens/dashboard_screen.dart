import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG icons
import 'history_screen.dart';
import 'add_data_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'package:fitsugar/widgets/bottom_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const AddDataScreen(), // Used as search screen
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'logo.png',
          height: 40,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // Removed the drawer property
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display some general stats
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text(
                    'Sugar Levels Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Average Sugar: 10g'), // Example stat
                  Text('Max Sugar: 20g'),
                  Text('Min Sugar: 5g'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Button to search/add food
          ElevatedButton(
            onPressed: () {
              // Change to the Search screen tab instead of navigating
              if (context.findAncestorStateOfType<_DashboardScreenState>() != null) {
                context.findAncestorStateOfType<_DashboardScreenState>()!._onItemTapped(1);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/solar_search_outline.svg',
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text('Add Food'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Display the list of foods entered by the user (optional)
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Example, replace with dynamic data
              itemBuilder: (context, index) {
                return ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/solar_food_outline.svg',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Food Item $index'),
                  subtitle: Text('Sugar: 15g'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}