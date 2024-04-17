import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//globale variabler
String? currentUserEmail;
String globalTagData = '';
String lesson = '';
int typeScan = 0;
int _buttonState = 0;

//Køre programmet
void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

//gemmer variblerne inden under widgeten
class _HomePageState extends State<HomePage> {
  String _nfcTagData = '';
  bool _tagDetected = false;
  bool tjekud = false;
  bool _showScanText = false;

//det grafiske (knapper, baggrund, tekst osv.)
//Dokumentatonen brug til det grafiske
//https://docs.flutter.dev/ui/widgets/basics
//https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //baggrunds farve
      backgroundColor: const Color.fromARGB(255, 40, 33, 255),
      appBar: AppBar(
        //UI centeret titel osv.
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 40, 33, 200),
        //titlen
        title: const Text(
          'NFC Reader',
          style: TextStyle(color: Colors.white),
        ),
      ),
      //opretter en centeret body til knapper og tekst
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //viser start nfc reading knappen hvis _buttonstate er 0
            if (_buttonState == 0)
              ElevatedButton(
                //hvis knappen trykkes kaldes _startNFCReading
                onPressed: _tagDetected ? null : _startNFCReading,
                child: SizedBox(
                  //design af knap
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
            //tjek ud knapppen vises hvis _buttonstate er 1
            if (_buttonState == 1)
              ElevatedButton(
                //kalder _startNFCReading
                onPressed: _startNFCReading,
                //design af knap
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Text(
                      'Tjek ud',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 60),
            //Hvis _showScanText er sant vises scan NFC tag
            //teksten vises når start nfc reading eller tjek ud er trykket på
            Text(
              _showScanText ? 'Scan NFC Tag' : '',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            //Viser dataen fra nfctagget
            // så vis dataet er registeret eller vis der er sket en fejl osv.
            Text(
              'NFC Tag Detected: $_nfcTagData',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            // log ud knappen
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

//funktion til at læse nfctag
//Dele af _startNFCReading() er taget fra https://medium.com/@codetrade/implement-nfc-in-flutter-to-transfer-peer-to-peer-data-64efeaa5377c d 11.03.2024
  void _startNFCReading() async {
    //gør at _showscantext er sand
    setState(() {
      _showScanText = true;
    });

    //tjekker om nfc scanning er muligt
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //hvis der er scanner den nfc tagget
      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            setState(() {
              //tjekker om tjek ud er sket
              if (_buttonState == 1) {
                tjekud = true;
                _buttonState = 0;
                print("tjek ud coplete");
              }

              //sætter forskellige variabler for eksemoelk nfc tag id
              globalTagData = tag.data['nfca']['identifier'].toString();
              _nfcTagData = '\nFremmøde er registreret';
              _tagDetected = true;
              //finder lektionen
              lesson = _getLessonFromTag(globalTagData);
              _updateFirestore();
              _startResetTimer();
              print('Tag Data: $globalTagData');
              _showScanText = false; // Fjerner teksten her
            });
          },
        );
        //evenutelle fejl
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

  //Finder hvilken lektion tagget er ved at kende forskellige tags id
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
    } else {
      return 'Ukendt';
    }
  }

// Sørger for eleven har tjekket ud
  void _startResetTimer() {
    if (tjekud == true) {
      setState(() {
        _tagDetected = false;
        _nfcTagData = '';
        tjekud = false;
      });
    } else {
      //starter en timer efter 10 sekunder hvis der ikke er blevet tjekket ud
      Timer(Duration(seconds: 10), () {
        _tjekUdUdLobet();
        setState(() {
          //gør at tjek ud knappen er synlig
          _buttonState = 1;
          _tagDetected = false;
          _nfcTagData = '';
        });
      });
    }
  }

//giver 10 sekunder tuk at tjkke ud og så  kalder den _setUserEmailTofalse
  void _tjekUdUdLobet() {
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

  //opdatere databsen
  //dokumentationen til at ændre data i databsen er fundet på firebase hjemmeside https://firebase.google.com/docs/firestore/manage-data/add-data
  void _updateFirestore() async {
    try {
      //henter emailen/brugernavnet der er logget ind som bruges til at opdatere den rigtige bruges fravær
      String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      String sanitizedEmail = currentUserEmail.replaceAll('.', '-');
      sanitizedEmail = sanitizedEmail.replaceAll('-', '.');

      //tjekker om stien er i databasen
      var userSnapshot = await FirebaseFirestore.instance
          .collection('3.A')
          .doc(sanitizedEmail)
          .get();

      // hvis stien er der køre koden der opdatere lektionen til true
      if (userSnapshot.exists) {
        if (!(userSnapshot.data()![lesson] ?? false)) {
          await FirebaseFirestore.instance
              .collection('3.A')
              .doc(sanitizedEmail)
              .update({lesson: true});
          print('Firestore opdateret med lektion: $lesson');
        }
        //evenetuelle fejæ
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

      //tjekker om lokationene er i databasen
      var userSnapshot = await FirebaseFirestore.instance
          .collection('3.A')
          .doc(sanitizedEmail)
          .get();

      //hvis loaktionen er i databasen ig buttonState er 1 køre koden der giver fravær
      if (userSnapshot.exists && _buttonState == 1) {
        print(tjekud);
        print(_nfcTagData);
        print(_tagDetected);
        print(_buttonState);

        await FirebaseFirestore.instance
            .collection('3.A')
            .doc(sanitizedEmail)
            .update({lesson: false});
        print('Firestore opdateret med lektion: false');
        setState(() {
          _buttonState = 0;
        });
        //hvis tjek ud er klaret printer den det og sætter _buttonState til 0
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

//funktion til at logge brugeren ud
  void _signOut(BuildContext context) {
    AuthPage().signOut(context);
  }
}
