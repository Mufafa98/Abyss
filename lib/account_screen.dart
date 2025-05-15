import 'package:abyss/prod_list_provider.dart';
import 'package:abyss/theme_provider.dart';
import 'package:abyss/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation_bar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _name = 'Mufafa98';

  Widget _buildProfile(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(top: 50, left: 10, right: 10),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: screenWidth,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75),
                    bottomLeft: Radius.circular(75),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75),
                    bottomLeft: Radius.circular(75),
                  ),
                  child: Image.asset(
                    'assets/SVG/profile_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 77, // Increased radius for white border
                backgroundColor: themeProvider.colorScheme.primary,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage(
                    'assets/SVG/profile_image.jpg',
                  ), // Replace with your image path
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            _name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(color: Colors.white, fontSize: 24),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width - 20;
    return SizedBox(
      width: screenWidth,
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            title: 'Watched Movies',
            count: Provider.of<WatchedListProvider>(context).movieCount,
            color: themeProvider.colorScheme.primary,
          ),
          _buildStatCard(
            context,
            title: 'Watched TVs',
            count: Provider.of<WatchedListProvider>(context).tvCount,
            color: themeProvider.colorScheme.secondary,
          ),
          _buildStatCard(
            context,
            title: 'Watched Episodes',
            count: Provider.of<WatchedListProvider>(context).episodeCount,
            color: themeProvider.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Provider.of<ThemeProvider>(context).colorScheme.secondary,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Provider.of<ThemeProvider>(context).colorScheme.onPrimary,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfile(context),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  _buildStats(context),
                  SizedBox(height: 20),
                  _buildButton(context, 'Change Name', () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Change Name'),
                          content: TextField(
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Enter new name",
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
                  SizedBox(height: 10),
                  _buildButton(context, 'Change Password', () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Change Password'),
                          content: TextField(
                            onChanged: (value) {
                              // Handle password input
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter new password",
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
                  SizedBox(height: 10),
                  _buildButton(context, 'Log Out', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            AbyssNavigationBar(initialIndex: 2),
          ],
        ),
      ),
    );
  }
}
