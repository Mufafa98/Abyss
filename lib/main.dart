import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => RootApp();
}

class DarkColors {
  static final Color background = Color(0xFF0D0208);
  static final Color backgroundSecondary = Color(0xFF1A0A0A);
  static final Color text = Color(0xFFE1D5C7);
  static final Color textSecondary = Color(0xFFBDA384);
  static final Color primary = Color(0xFFFF2200);
  static final Color secondary = Color(0xFFB8100A);
  static final Color accent = Color(0xFFF48B13);
}

class RootApp extends State<MyApp> {
  ThemeData theme = ThemeData(
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      title: 'Abyss',
      theme: theme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/SVG/HomeScreenGradient.svg',
                      width: size.width,
                      height: size.height * 0.6,
                      fit: BoxFit.fill,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Stare long enough\ninto the ",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                            text: "Abyss",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          TextSpan(
                            text: "\nand it will stare back",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Begin the Descent",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No spoilers. No judgement. Just the void",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
