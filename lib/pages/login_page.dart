import 'package:flutter/material.dart';
import 'package:fravar_nfc/components/my_button.dart';
import 'package:fravar_nfc/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // tekst redigering controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void logUserIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

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

                //Velkommen tilbage
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

                //log-in
                MyButton(
                  onTap: logUserIn,
                ),

                const SizedBox(height: 10),

                //continue

                //google appel (skal ikke med i færdige produkt)
              ],
            ),
          ),
        ));
  }
}
