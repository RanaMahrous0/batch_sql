import 'package:flutter/material.dart';

class MySearchTextField extends StatelessWidget {
final void Function(String)? onChanged;
  final TextEditingController? controller;
  const MySearchTextField(
      {required this.onChanged,
      this.controller,
      
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).primaryColor,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        label: const Text('Search'),
      ),
    );
  }
}
