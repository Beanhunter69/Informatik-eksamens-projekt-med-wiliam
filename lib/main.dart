import 'package:flutter/material.dart';
import 'package:fravar_nfc/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//main opretter en simpel flutter app der sætter AuthPage() som startsiden

void main() async {
  // Sørger for databasen er indlæst inden koden køre
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //indlæser firebase med firebase indstillingerne
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //køre koden
  runApp(const MyApp());
}

//definer StatelessWidget som bruges til hele appen
class MyApp extends StatelessWidget {
  //konstruktøren
  const MyApp({super.key});

  @override
  //metode til at bygge widget
  Widget build(BuildContext context) {
    //retunere widget som er grundlaget for flutter appen
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //stææter AuthPage til startsiden for appen
      home: AuthPage(),
    );
  }
}
