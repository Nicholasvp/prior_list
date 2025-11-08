import 'package:flutter/material.dart';

class TextFormPrimary extends StatelessWidget {
  const TextFormPrimary({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
