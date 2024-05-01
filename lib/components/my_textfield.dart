import 'package:flutter/material.dart';

//Meget af koden er lavet udfra videon https://www.youtube.com/watch?v=4fucdtPwTWI&list=RDCMUCVj9dwfXRmwyYmiWnk-qCCQ&index=11&ab_channel=MitchKoko
//Den bruges til login siden auth siden og my_button og my_textfield.
//tilpasset tekstfelt widget.
class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

//konstruktøren
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

//Det visuelle for knappen
//https://docs.flutter.dev/ui/widgets/basics
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            fillColor: Colors.grey[300],
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}
