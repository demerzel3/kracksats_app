import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_biopass/flutter_biopass.dart' show BioPass;
import 'package:otp/otp.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isStacking = false;
  final _bioPass = BioPass();

  String generateTOTP(String secret) {
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_stack_3d_up),
              activeIcon: Icon(CupertinoIcons.square_stack_3d_up_fill),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bitcoin_circle),
              activeIcon: Icon(CupertinoIcons.bitcoin_circle_fill),
              label: "Buy")
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        if (index == 1) {
          // buy
          return Center(
            child: CupertinoButton.filled(
              padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
              child: _isStacking
                  ? CupertinoActivityIndicator()
                  : const Text('Stack some sats'),
              onPressed: () async {
                setState(() {
                  _isStacking = true;
                });
                final secret =
                    await _bioPass.retreive(withPrompt: "Retrieve TOTP secret");

                // No secret stored
                if (secret == null) {
                  // Prompt for the secret
                  final newSecret = await prompt(context);
                  // Store it
                  await _bioPass.store(newSecret);

                  print('Your fancy TOTP code is: ' +
                      this.generateTOTP(newSecret));
                } else {
                  print(
                      'Your fancy TOTP code is: ' + this.generateTOTP(secret));

                  setState(() {
                    _isStacking = false;
                  });
                }
              },
            ),
          );
        }

        return Center(child: const Text('You know what to do.'));
      },
    );
  }
}
