import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final double width;
  final double height;
  final double fontSize;

  const SizedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;
  final BuildContext context;

  const InputField({
    super.key,
    required this.context,
    required this.label,
    required this.isPassword,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
