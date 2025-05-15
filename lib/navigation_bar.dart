import 'package:abyss/home_screen.dart';
import 'package:abyss/theme_provider.dart';
import 'package:abyss/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'track.dart';

class AbyssNavigationBar extends StatefulWidget {
  final int initialIndex;

  const AbyssNavigationBar({super.key, required this.initialIndex});

  @override
  _AbyssNavigationBarState createState() => _AbyssNavigationBarState();
}

class _AbyssNavigationBarState extends State<AbyssNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            switch (index) {
              case 0:
                return TrackScreen();
              case 1:
                return HomeScreen();
              case 2:
                return AccountScreen();
              default:
                return HomeScreen();
            }
          },
        ),
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: theme.colorScheme.primary,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Track'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Discover',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        );
      },
    );
  }
}
