import 'package:flutter/material.dart';

class DarkColors {
  static final Color background = Color(0xFF0D0208);
  static final Color backgroundSecondary = Color(0xFF1A0A0A);
  static final Color text = Color(0xFFE1D5C7);
  static final Color textSecondary = Color(0xFFBDA384);
  static final Color primary = Color(0xFFFF2200);
  static final Color secondary = Color(0xFFB8100A);
  static final Color accent = Color(0xFFF48B13);
}

class ThemeProvider extends ChangeNotifier {
  ThemeData _theme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColors.primary,
      onPrimary: DarkColors.text,
      secondary: DarkColors.secondary,
      onSecondary: DarkColors.text,
      tertiary: DarkColors.accent,
      error: Color(0xFF000000),
      onError: Color(0xFFFFFFFF),
      surface: DarkColors.background,
      onSurface: DarkColors.text,
    ),
  );

  ThemeData get theme => _theme;

  void setTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }
}
