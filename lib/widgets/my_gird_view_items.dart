import 'package:flutter/material.dart';

class MyGirdViewItems extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const MyGirdViewItems(
      {required this.icon,
      required this.color,
      required this.label,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: color.withOpacity(.2),
            foregroundColor: color,
            child: Icon(
              icon,
              size: 30,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
          )
        ],
      ),
    );
  }
}
