import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fravar_nfc/pages/login_page.dart';
import 'home_page.dart';

//Meget af koden er lavet udfra videon https://www.youtube.com/watch?v=4fucdtPwTWI&list=RDCMUCVj9dwfXRmwyYmiWnk-qCCQ&index=11&ab_channel=MitchKoko
//Den bruges til login siden, auth siden, my_buttonm, my_textfield og opsætning af databasen.

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //Tjekker om brugen er logget ind
            if (snapshot.hasData) {
              //sender brugen til HomePage()
              return const HomePage();

              //Hvis brugen ikke er logget ind skal de være på LoginPage()
            } else {
              return LoginPage();
            }
          }),
    );
  }

//funktion til at logge brugen ud
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
