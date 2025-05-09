import 'package:abyss/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AbyssNavigationBar extends StatefulWidget {
  final int initialIndex;

  const AbyssNavigationBar({Key? key, required this.initialIndex})
    : super(key: key);

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
          selectedItemColor: theme.theme.colorScheme.primary,
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
