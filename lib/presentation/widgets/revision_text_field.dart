import 'package:flutter/material.dart';

class RevisionTextField extends StatelessWidget {
  const RevisionTextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.keyboardType,
    this.icon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType? keyboardType;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
