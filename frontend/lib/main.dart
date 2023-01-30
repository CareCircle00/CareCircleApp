import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';


import 'routes.dart' as r;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MaterialApp(
        initialRoute: '/splash_screen',
        // initialRoute: '/login_screen',
        // initialRoute: '/code_screen',
        // initialRoute: '/add_loved_one_screen',
        // initialRoute: '/contact_book_screen',
        // initialRoute: '/select_action_screen',
        // initialRoute: '/home_screen',
        // initialRoute: '/home_screen_loved_one',
        //   initialRoute : '/video_screen',
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