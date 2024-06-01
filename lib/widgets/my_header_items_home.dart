import 'package:flutter/material.dart';
class MyHeaderItem extends StatelessWidget {
  String label;
  String value;

   MyHeaderItem( {required this.label,required this.value ,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Card(
      color: const Color(0xff206ce1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            Text(
              value!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            )
          ],
        ),
      ),
    ),
  );
  }
}
