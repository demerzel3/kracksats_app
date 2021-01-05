import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kracksats_app/app.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // We have a dark theme, so we need light system UI style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.init("ebbeabeb-a380-4291-8d38-2b585f17f9e6", iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  });
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  runApp(App());
}
