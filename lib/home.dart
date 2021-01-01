import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_biopass/flutter_biopass.dart' show BioPass;
import 'package:kracksats_app/api.dart';
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
  Future<Order> _futureOrder;
  final _bioPass = BioPass();

  String _generateTOTP(String secret) =>
      OTP.generateTOTPCodeString(secret, DateTime.now().millisecondsSinceEpoch,
          algorithm: Algorithm.SHA1, interval: 30, length: 6, isGoogle: true);

  Future<String> _retrieveSecret() =>
      _bioPass.retreive(withPrompt: "Retrieve TOTP secret");

  Future<String> _promptAndStoreSecret() async {
    // Prompt for the secret
    final newSecret = await prompt(context);
    // Store it
    await _bioPass.store(newSecret);

    return newSecret;
  }

  Future<String> _getSecret() async {
    final storedSecret = await _retrieveSecret();
    return storedSecret != null ? storedSecret : await _promptAndStoreSecret();
  }

  Widget _buildBuyButton(BuildContext context) {
    return CupertinoButton.filled(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: const Text('Stack some sats'),
      onPressed: () async {
        setState(() {
          _isStacking = true;
        });
        final secret = await _getSecret();
        final otp = _generateTOTP(secret);

        setState(() {
          _futureOrder = newOrder(otp);
        });
      },
    );
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
            child: _isStacking
                ? FutureBuilder<Order>(
                    future: _futureOrder,
                    builder: (context, snapshot) {
                      final reset = () {
                        setState(() {
                          _isStacking = false;
                          _futureOrder = null;
                        });
                      };

                      if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Fucking legend!"),
                            SizedBox(height: 16),
                            CupertinoButton(
                                child: const Text('Ok'), onPressed: reset),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${snapshot.error}"),
                            SizedBox(height: 16),
                            CupertinoButton(
                                child: const Text('Ok'), onPressed: reset),
                          ],
                        );
                      }

                      return CupertinoActivityIndicator();
                    },
                  )
                : _buildBuyButton(context),
          );
        }

        return Center(child: const Text('You know what to do.'));
      },
    );
  }
}
