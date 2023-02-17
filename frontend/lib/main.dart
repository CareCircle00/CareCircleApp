import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'routes.dart' as r;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MaterialApp(
        initialRoute: user == null?'/video_screen': '/splash_screen',
        // initialRoute: '/video_screen',
        // initialRoute: '/splash_screen',
        // initialRoute: '/login_screen',
        // initialRoute: '/code_screen',
        // initialRoute: '/add_loved_one_screen',
        // initialRoute: '/contact_book_screen',
        // initialRoute: '/select_action_screen',
        // initialRoute: '/home_screen',
        // initialRoute: '/home_screen_loved_one',
        // initialRoute: '/setup_screen',
        routes:r.routes
      )
    );
  });
  // runApp(
  //   MaterialApp(
  //     initialRoute: '/splash_screen',
  //     // initialRoute: '/login_screen',
  //     // initialRoute: '/code_screen',
  //     // initialRoute: '/add_loved_one_screen',
  //     // initialRoute: '/contact_book_screen',
  //     // initialRoute: '/select_action_screen',
  //     // initialRoute: '/home_screen',
  //     routes:r.routes
  //   )
  // );
}