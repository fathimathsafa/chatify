import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  const CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.controller,
    this.validator,   this.obscureText=false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        obscureText:obscureText ,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
