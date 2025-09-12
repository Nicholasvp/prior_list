import 'package:flutter/material.dart';

class DropDownPrimary extends StatelessWidget {
  const DropDownPrimary({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: <String>['One', 'Two', 'Free', 'Four'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (_) {},
    );
  }
}
