import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:meteo_du_numerique/presentation/screens/home.dart';

import 'firebase_options.dart';
import 'message.dart';
import 'token_monitor.dart';

/// Working example of FirebaseMessaging.
/// Please use this in order to verify messages are working in foreground, background & terminated state.
/// Setup your app following this guide:
/// https://firebase.google.com/docs/cloud-messaging/flutter/client#platform-specific_setup_and_requirements):
///
/// Once you've completed platform specific requirements, follow these instructions:
/// 1. Install melos tool by running `flutter pub global activate melos`.
/// 2. Run `melos bootstrap` in FlutterFire project.
/// 3. In your terminal, root to ./packages/firebase_messaging/firebase_messaging/example directory.
/// 4. Run `flutterfire configure` in the example/ directory to setup your app with your Firebase project.
/// 5. Run the app on an actual device for iOS, android is fine to run on an emulator.
/// 6. Use the following script to send a message to your device: scripts/send-message.js. To run this script,
///    you will need nodejs installed on your computer. Then the following:
///     a. Download a service account key (JSON file) from your Firebase console, rename it to "google-services.json" and add to the example/scripts directory.
///     b. Ensure your device/emulator is running, and run the FirebaseMessaging example app using `flutter run`.
///     c. Copy the token that is printed in the console and paste it here: https://github.com/firebase/flutterfire/blob/01b4d357e1/packages/firebase_messaging/firebase_messaging/example/lib/main.dart#L32
///     c. From your terminal, root to example/scripts directory & run `npm install`.
///     d. Run `npm run send-message` in the example/scripts directory and your app will receive messages in any state; foreground, background, terminated.
///  Note: Flutter API documentation for receiving messages: https://firebase.google.com/docs/cloud-messaging/flutter/receive
///  Note: If you find your messages have stopped arriving, it is extremely likely they are being throttled by the platform. iOS in particular
///  are aggressive with their throttling policy.
///
/// To verify that your messages are being received, you ought to see a notification appearon your device/emulator via the flutter_local_notifications plugin.
/// Define a top-level named handler which background/terminated messages will
/// call. Be sure to annotate the handler with `@pragma('vm:entry-point')` above the function declaration.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // FirebaseMessaging.instance.subscribeToTopic('fcm_test');
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('authToken');

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {}

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  runApp(const MyApp());

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // Set the background messaging handler early on, as a named top-level function
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // if (!kIsWeb) {
  //   await setupFlutterNotifications();
  // }
  //
  // runApp(MessagingExampleApp());
}

/// Entry point for the example application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => const Application(),
        '/message': (context) => const MessageView(),
      },
    );
  }
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

/// Renders the example application.
class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  String? _token;
  String? initialMessage;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();

    requestPermission();

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              _resolved = true;
              initialMessage = value?.data.toString();
            },
          ),
        );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(
        context,
        '/message',
        arguments: MessageArguments(message, true),
      );
    });
    if (!kIsWeb) {
      FirebaseMessaging.instance.subscribeToTopic('fcm_test');
      print(
        'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.',
      );
    }
  }

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          print(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.',
          );
        }
        break;
      case 'unsubscribe':
        {
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.',
          );
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            print('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            print(
              'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ValueListenableBuilder(
        valueListenable: Hive.box('authToken').listenable(),
        builder: (context, Box box, _) {
          // if (box.isEmpty) {
          // print(box.isEmpty);
          //   return Login(
          //     box: box,
          //   );
          // } else {
          return Home(
            box: box,
          );
          // }
        },
      ),
    );
  }
}

class MyaApp extends StatelessWidget {
  const MyaApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: ValueListenableBuilder(
        valueListenable: Hive.box('auth').listenable(),
        builder: (context, Box box, _) {
          // if (box.values.isEmpty) {
          //   return Login(
          //     box: box,
          //   );
          // } else {
          return Home(
            box: box,
          );
          // }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String? _token;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            TokenMonitor(((token) {
              _token = token;
              return token == null
                  ? const CircularProgressIndicator()
                  : Text(token, style: const TextStyle(fontSize: 12));
            })),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MaterialApp(home: MyApp()));
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// int toggle = 0;
//
// class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
//   late AnimationController _con;
//   late TextEditingController _textEditingController;
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController();
//     _con = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 375),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Color(0xffF2F3F7),
//         child: Center(
//           child: Container(
//             height: 100.0,
//             width: 450.0,
//             alignment: Alignment(-1.0, 0.0),
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 375),
//               height: 48.0,
//               width: (toggle == 0) ? 48.0 : 250.0,
//               curve: Curves.easeOut,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     spreadRadius: -10.0,
//                     blurRadius: 10.0,
//                     offset: Offset(0.0, 10.0),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   AnimatedPositioned(
//                     duration: Duration(milliseconds: 375),
//                     top: 6.0,
//                     right: 7.0,
//                     curve: Curves.easeOut,
//                     child: AnimatedOpacity(
//                       opacity: (toggle == 0) ? 0.0 : 1.0,
//                       duration: Duration(milliseconds: 200),
//                       child: Container(
//                         padding: EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           color: Color(0xffF2F3F7),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         // child: AnimatedBuilder(
//                         //   child: Icon(
//                         //     Icons.mic,
//                         //     size: 20.0,
//                         //   ),
//                         //   builder: (context, widget) {
//                         //     return Transform.rotate(
//                         //       angle: _con.value * 2.0 * pi,
//                         //       child: widget,
//                         //     );
//                         //   },
//                         //   animation: _con,
//                         // ),
//                       ),
//                     ),
//                   ),
//                   AnimatedPositioned(
//                     duration: Duration(milliseconds: 375),
//                     left: (toggle == 0) ? 20.0 : 40.0,
//                     curve: Curves.easeOut,
//                     top: 11.0,
//                     child: AnimatedOpacity(
//                       opacity: (toggle == 0) ? 0.0 : 1.0,
//                       duration: Duration(milliseconds: 200),
//                       child: Container(
//                         height: 23.0,
//                         width: 180.0,
//                         child: TextField(
//                           controller: _textEditingController,
//                           cursorRadius: Radius.circular(10.0),
//                           cursorWidth: 2.0,
//                           cursorColor: Colors.black,
//                           decoration: InputDecoration(
//                             floatingLabelBehavior: FloatingLabelBehavior.never,
//                             labelText: 'Search...',
//                             labelStyle: TextStyle(
//                               color: Color(0xff5B5B5B),
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             alignLabelWithHint: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(20.0),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Material(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30.0),
//                     child: IconButton(
//                       splashRadius: 19.0,
//                       icon: Icon(
//                         Icons.mic,
//                         size: 20.0,
//                       ),
//                       onPressed: () {
//                         setState(
//                               () {
//                             if (toggle == 0) {
//                               toggle = 1;
//                               _con.forward();
//                             } else {
//                               toggle = 0;
//                               _textEditingController.clear();
//                               _con.reverse();
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }