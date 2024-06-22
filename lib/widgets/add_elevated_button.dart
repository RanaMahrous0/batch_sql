import 'package:flutter/material.dart';

class MyAppElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  const MyAppElevatedButton(
      {required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: const Size(double.maxFinite, 60),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
