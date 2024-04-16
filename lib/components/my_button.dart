import 'package:flutter/material.dart';

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
