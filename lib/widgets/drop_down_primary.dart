import 'package:flutter/material.dart';

class DropDownPrimary extends StatelessWidget {
  const DropDownPrimary({super.key, required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),

      underline: SizedBox.shrink(),
      onChanged: (_) {},
    );
  }
}
