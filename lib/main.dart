import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'welcome_screen.dart';
import 'theme_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(), child: Root()),
  );
}

class Root extends StatelessWidget {
  // final ThemeProvider themeProvider = ThemeProvider();

  Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Abyss',
          theme: theme.theme,
          home: Builder(builder: (context) => WelcomeScreen()),
        );
      },
    );
  }
}
