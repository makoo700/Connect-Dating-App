import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dating_app/services/auth_service.dart';
import 'package:flutter_dating_app/screens/swipe_screen.dart';
import 'package:flutter_dating_app/screens/matches_screen.dart';
import 'package:flutter_dating_app/screens/messages_screen.dart';
import 'package:flutter_dating_app/screens/events_screen.dart';
import 'package:flutter_dating_app/screens/profile_screen.dart';
import 'package:flutter_dating_app/screens/gallery_screen.dart';
import 'package:flutter_dating_app/main.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SwipeScreen(),
    MatchesScreen(),
    MessagesScreen(),
    EventsScreen(),
    ProfileScreen(),
    GalleryScreen(),
  ];

  final List<String> _titles = [
    'Discover',
    'Matches',
    'Messages',
    'Events',
    'Profile',
    'Gallery',
  ];

  @override
  Widget build(BuildContext context) {
    return LostDataWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          backgroundColor: Color(0xFF1E88E5), // Changed from pink to blue
          actions: [
            if (_currentIndex == 0)
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter dialog
                  _showFilterDialog();
                },
              ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Logout
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF1E88E5), // Changed from pink to blue
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Preferences'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Age Range Slider
                Text('Age Range'),
                RangeSlider(
                  values: RangeValues(18, 35),
                  min: 18,
                  max: 100,
                  divisions: 82,
                  labels: RangeLabels('18', '35'),
                  onChanged: (RangeValues values) {
                    // Update age range
                  },
                ),

                // Gender Preference
                Text('Gender Preference'),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Male'),
                      selected: true,
                      onSelected: (selected) {
                        // Update gender preference
                      },
                    ),
                    ChoiceChip(
                      label: Text('Female'),
                      selected: false,
                      onSelected: (selected) {
                        // Update gender preference
                      },
                    ),
                    ChoiceChip(
                      label: Text('Other'),
                      selected: false,
                      onSelected: (selected) {
                        // Update gender preference
                      },
                    ),
                  ],
                ),

                // Distance Slider
                Text('Maximum Distance'),
                Slider(
                  value: 50,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '50 km',
                  onChanged: (value) {
                    // Update distance
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply filters
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
