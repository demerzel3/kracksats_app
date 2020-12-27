import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'dart:async';

import 'package:flutter_biopass/flutter_biopass.dart' show BioPass;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otp/otp.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // _tags is a list of scanned tags
  final _bioPass = BioPass();
  List<String> _tags = [];

  void _readNFC(BuildContext context) {
    FlutterNfcReader.read().then((response) {
      setState(() {
        _tags.insert(0, response.content);
      });
    });
  }

  String generateTOTP(String secret) {
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('NFC in Flutter'),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return FlatButton(
                  child: Text("Read tag"),
                  onPressed: () {
                    _readNFC(context);
                  },
                );
              },
            ),
            FlatButton(
                child: Text("Generate code"),
                onPressed: () async {
                  final secret = await _bioPass.retreive(
                      withPrompt: "Retrieve TOTP secret");

                  // No secret stored
                  if (secret == null) {
                    // Prompt for the secret
                    final newSecret = await prompt(context);
                    // Store it
                    await _bioPass.store(newSecret);

                    print('Your fancy TOTP code is: ' +
                        this.generateTOTP(newSecret));
                  } else {
                    print('Your fancy TOTP code is: ' +
                        this.generateTOTP(secret));
                  }
                }),
            FlatButton(
                child: Text("Notifications"),
                onPressed: () {
                  OneSignal.shared.promptUserForPushNotificationPermission(
                      fallbackToSettings: true);
                }),
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _tags.clear();
                });
              },
              tooltip: "Clear",
            ),
          ],
        ),
        // Render list of scanned tags
        body: ListView.builder(
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            const TextStyle payloadTextStyle = const TextStyle(
              fontSize: 15,
              color: const Color(0xFF454545),
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("NDEF Tag",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Builder(
                    builder: (context) {
                      /*
                      // Build list of records
                      List<Widget> records = [];
                      for (int i = 0; i < _tags[index].records.length; i++) {
                        records.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Record ${i + 1} - ${_tags[index].records[i].type}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            Text(
                              _tags[index].records[i].payload,
                              style: payloadTextStyle,
                            ),
                            Text(
                              _tags[index].records[i].data,
                              style: payloadTextStyle,
                            ),
                          ],
                        ));
                      }
                      */
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _tags[index],
                              style: payloadTextStyle,
                            ),
                          ]);
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
