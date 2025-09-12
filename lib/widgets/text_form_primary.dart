import 'package:flutter/material.dart';

class TextFormPrimary extends StatelessWidget {
  const TextFormPrimary({
    super.key,
    this.label,
    this.hintText,
    this.controller,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
