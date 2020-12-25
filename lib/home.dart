import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'dart:async';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // _tags is a list of scanned tags
  List<String> _tags = [];

  void _readNFC(BuildContext context) {
    FlutterNfcReader.read().then((response) {
      setState(() {
        _tags.insert(0, response.content);
      });
    });
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
