import 'package:flutter/material.dart';
import 'package:fravar_nfc/components/my_button.dart';
import 'package:fravar_nfc/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Meget af koden er lavet udfra videon https://www.youtube.com/watch?v=4fucdtPwTWI&list=RDCMUCVj9dwfXRmwyYmiWnk-qCCQ&index=11&ab_channel=MitchKoko
//Den bruges til login siden auth siden og my_button og my_textfield.

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // tekst redigering kontroller
  // dokumentation er fundet fra https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

//funktion til at logge brugenen ind
// dokumentation fundet på https://firebase.google.com/docs/auth/android/password-auth
  void logUserIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

//det grafiske
//Dokumentatonen brug til det grafiske
//https://docs.flutter.dev/ui/widgets/basics
//https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 40, 33, 255),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),

                //logo
                const Text(
                  'UNI-Login',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 50,
                  ),
                ),

                const SizedBox(height: 30),

                //Velkommen tilbage tekst
                const Text(
                  'Velkommen tilbage',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //Uni-login brugernavn
                MyTextField(
                  controller: emailController,
                  hintText: 'Brugernavn',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //Uni-login kode

                MyTextField(
                  controller: passwordController,
                  hintText: 'Adgangskode',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Glemt password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Glemt adgangskode?",
                        style: TextStyle(color: Colors.grey[200]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //log-in knap
                MyButton(
                  onTap: logUserIn,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}
