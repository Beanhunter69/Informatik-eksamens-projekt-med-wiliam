import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// globale variabler
String? currentUserEmail;
String globalTagData = '';
String lesson = '';
int typeScan = 0;
int _buttonState = 0;

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
  bool tjekud = false;

//det grafiske
//Dokumentatonen brug til det grafiske
//https://docs.flutter.dev/ui/widgets/basics
//https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //design af baggrund og tekst
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
          children: <Widget>[
            // Vis kun hvis _buttonState er forskellig fra 1
            if (_buttonState == 0)
              ElevatedButton(
                //når knappen trykkes skal _startNFCReading starte
                onPressed: _tagDetected ? null : _startNFCReading,
                child: SizedBox(
                  //design
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

            // Vis kun hvis _buttonState er lig med 1
            if (_buttonState == 1)
              ElevatedButton(
                //starter _startNfcReading når knappen trykkes
                onPressed: _startNFCReading,
                child: Text('Tjek ud'),
              ),
            const SizedBox(height: 60),
            Text(
              'NFC Tag Detected: $_nfcTagData',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(
                height: 20), // Tilføjet mellemrum mellem tekst og knap
            ElevatedButton(
              //log ud knap skalder_signOut
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

//funtiont til at scanne nfctag
//Dele af _startNFCReading() er taget fra https://medium.com/@codetrade/implement-nfc-in-flutter-to-transfer-peer-to-peer-data-64efeaa5377c d 11.03.2024
  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            setState(() {
              //Hvis _buttonsState er lig med 1 skal den tjekke ud. Dette sker når nfc tagget er scannet en gang.
              if (_buttonState == 1) {
                tjekud = true;
                _buttonState =
                    0; // Sætter _buttonState tilbage til 0 når scanningen er færdig
                print("tjek ud coplete");
              }

              //henter tagid'et/data
              globalTagData = tag.data['nfca']['identifier'].toString();
              //sææter variablen så teskten kan ændre til fremøde er registerert
              _nfcTagData = '\nFremmøde er registreret';
              //variablen brug til at sætte at et tag er fundet.
              _tagDetected = true;
              //kalder _getLessonFromTag som finder ud af hvilket lektion tagget er tilsvarende.
              lesson = _getLessonFromTag(globalTagData);
              //kalder de to funktioner
              _updateFirestore();
              _startResetTimer();
              //printer tag data'et
              print('Tag Data: $globalTagData');
            });
          },
        );
        //eventuelle fejl registeres
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

  //funktion til at bestemme lektionen baseret på tagid'et
  String _getLessonFromTag(String tagData) {
    if (tagData == '[4, 217, 213, 169, 121, 0, 0]' ||
        tagData == '[4, 39, 139, 178, 121, 0, 0]') {
      return 'DANSK';
    } else if (tagData == '[4, 102, 6, 181, 121, 0, 0]' ||
        tagData == '[4, 24, 90, 171, 121, 0, 0]') {
      return 'MATEMATIK';
    } else if (tagData == '[4, 125, 185, 176, 121, 0, 0]' ||
        tagData == '[4, 51, 115, 169, 121, 0, 0]') {
      return 'TEKNIKFAG';
      // Hvis taggen ikke matcher nogen kendt lektion
    } else {
      return 'Ukendt';
    }
  }

  //startes når nfctagger indlæses
  void _startResetTimer() {
    //hvis der er tjekket ud sørger den for variablerne til sat tilbage
    //så der kan scannes et nyt tag
    if (tjekud == true) {
      setState(() {
        _tagDetected = false;
        _nfcTagData = '';
        tjekud = false;
      });
      //hvis tjek ud ikke er taget starter der en timer på 10 sekunder der gør at tjek ud knappen bliver vist efter.
    } else {
      Timer(Duration(seconds: 10), () {
        _tjekUdUdLobet();
        setState(() {
          _buttonState = 1;
          _tagDetected = false;
          _nfcTagData = '';
        });
      });
    }
  }

  void _tjekUdUdLobet() {
    //giver 10 sekunder til at tjekke ud enden der bliver givet fravær.
    Timer(Duration(seconds: 10), () {
      if (!tjekud) {
        print("tiden er udløbet");
        _setUserEmailToFalse();
        setState(() {
          _tagDetected = false;
          _nfcTagData = '';
        });
      }
    });
  }

  void _updateFirestore() async {
    try {
      //henter emailen/brugernavnet der er logget ind som bruges til at opdatere den rigtige bruges fravær
      String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      //gør syntaxen korrekt i emailen
      String sanitizedEmail = currentUserEmail.replaceAll('.', '-');
      sanitizedEmail = sanitizedEmail.replaceAll('-', '.');

      //dokumentationen er funder på firebase hjemmeside https://firebase.google.com/docs/firestore/manage-data/add-data
      var userSnapshot = await FirebaseFirestore.instance
          .collection('3.A')
          .doc(sanitizedEmail)
          .get();

      //hvis databasen kunne finde lokationen på dateet skal den opdatere lektionen
      if (userSnapshot.exists) {
        //tjekker om lektionen allerede er opdateret
        if (!(userSnapshot.data()![lesson] ?? false)) {
          await FirebaseFirestore.instance
              .collection('3.A')
              .doc(sanitizedEmail)
              .update({lesson: true});
          print('Firestore opdateret med lektion: $lesson');
        }
        //eventuelle fejl
      } else {
        print(
            'Dokumentet for brugeren findes ikke i Firestore-databasen under "3.A".');
      }
    } catch (e) {
      print('Fejl ved opdatering af Firestore: $e');
    }
  }

  //Funktion bruges til at sætte brugenes e-mail til false hvis tjek-ud ikke blev gennemført.
  void _setUserEmailToFalse() async {
    try {
      //henter emailen/brugernavnet der er logget ind som bruges til at opdatere den rigtige bruges fravær
      String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      String sanitizedEmail = currentUserEmail.replaceAll('.', '-');

      sanitizedEmail = sanitizedEmail.replaceAll('-', '.');

      //finder om lokationen findes i datasanen
      var userSnapshot = await FirebaseFirestore.instance
          .collection('3.A')
          .doc(sanitizedEmail)
          .get();

      //hvis den gør og _buttonState er lig med 1 skal der gives fravær
      if (userSnapshot.exists && _buttonState == 1) {
        print(tjekud);
        print(_nfcTagData);
        print(_tagDetected);
        print(_buttonState);
        //opdater lektionen til false for bruger
        await FirebaseFirestore.instance
            .collection('3.A')
            .doc(sanitizedEmail)
            .update({lesson: false});
        print('Firestore opdateret med lektion: false');
        setState(() {
          _buttonState = 0;
        });
        //hvis der er tjekket ud
      } else {
        print('Tjek ud belv gennemført');
        setState(() {
          _buttonState = 0;
        });
      }
      //eventuelle fejl
    } catch (e) {
      print('Fejl ved opdatering af Firestore: $e');
    }
  }

// Log ud af Firebase Authentication ved brug af auth_page.dart
  void _signOut(BuildContext context) {
    AuthPage().signOut(context);
  }
}
