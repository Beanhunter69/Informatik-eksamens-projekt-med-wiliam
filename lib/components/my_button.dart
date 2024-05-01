import 'package:flutter/material.dart';

//Meget af koden er lavet udfra videon https://www.youtube.com/watch?v=4fucdtPwTWI&list=RDCMUCVj9dwfXRmwyYmiWnk-qCCQ&index=11&ab_channel=MitchKoko
//Den bruges til login siden auth siden og my_button og my_textfield.
// tilpasset knap widget
class MyButton extends StatelessWidget {
  final Function()? onTap;

  //kosntruktør
  const MyButton({super.key, required this.onTap});

//design
//https://docs.flutter.dev/ui/widgets/basics
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Log-in',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
