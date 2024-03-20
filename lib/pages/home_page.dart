import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'auth_page.dart'; // Importér login-siden
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _nfcTagData = '';
  bool _tagDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 33, 255),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 40, 33, 200),
        title: const Text(
          'NFC Reader',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _tagDetected ? null : _startNFCReading,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: _tagDetected
                      ? Icon(Icons.check, color: Colors.white, size: 60)
                      : const Text(
                          'Start NFC Reading',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
                backgroundColor: _tagDetected
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              'NFC Tag Detected: $_nfcTagData',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(
                height: 20), // Tilføjet mellemrum mellem tekst og knap
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              child: Text('Log ud'),
            ),
          ],
        ),
      ),
    );
  }

  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            setState(() {
              //_nfcTagData = tag.data.toString(); !!!!!!!!!!
              _nfcTagData = 'Fravær Registret';
              _tagDetected = true; // Markér at tag er blevet opdaget
              _startResetTimer();
              _updateFirestore(); // Kald metode til at opdatere Firestore
            });
          },
        );
      } else {
        setState(() {
          _nfcTagData = 'NFC not available.';
        });
      }
    } catch (e) {
      setState(() {
        _nfcTagData = 'Error reading NFC: $e';
      });
    }
  }

  void _startResetTimer() {
    Timer(Duration(seconds: 10), () {
      setState(() {
        _tagDetected = false;
        _nfcTagData = '';
        //'$currentUserEmail': false
      });
    });
  }
}

void _updateFirestore() async {
  try {
    // Hent den aktuelle brugers e-mail fra Firebase Authentication
    String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

    // Kontroller om brugeren eksisterer i Firestore-databasen
    var userSnapshot = await FirebaseFirestore.instance
        .collection('3.N') // Stien til dokumentet "3.N"
        .doc('DANSK_A')
        .get();

    if (userSnapshot.exists) {
      // Opdater boolean-variablen til true
      await FirebaseFirestore.instance.collection('3.N').doc('DANSK_A').update({
        '$currentUserEmail': true
      }); // Opdaterer boolean-værdien med brugerens e-mail
      print('Firestore opdateret!');
    } else {
      print(
          'Dokumentet "DANSK_A" findes ikke i Firestore-databasen under "3.N".');
    }
  } catch (e) {
    print('Fejl ved opdatering af Firestore: $e');
  }
}

void _signOut(BuildContext context) {
  AuthPage().signOut(context); // Log ud af Firebase Authentication
}
