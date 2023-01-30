import 'package:flutter/cupertino.dart';

import 'screens/login.dart' as login_screen;
import 'screens/code.dart' as code_screen;
import 'screens/add_loved_one.dart' as add_loved_one_screen;
import 'screens/splash.dart' as splash_screen;
import 'screens/contact_book.dart' as contact_book_screen;
import 'screens/select_action.dart' as select_action_screen;
import 'screens/home/home.dart' as home_screen;
import 'screens/home2/home_loved_one.dart' as home_loved_one_screen;
import 'screens/video.dart' as video_screen;

var routes = <String,WidgetBuilder>{
  '/splash_screen': (context)=> const splash_screen.SplashScreen(),
  '/login_screen' : (context)=> const login_screen.LoginScreen(),
  '/code_screen' : (context) => const code_screen.CodeScreen(),
  '/add_loved_one_screen' : (context) => const add_loved_one_screen.AddLovedOneScreen(),
  '/contact_book_screen' : (context)=> const contact_book_screen.ContactBookScreen(),
  '/select_action_screen' : (context)=> const select_action_screen.SelectActionScreen(),
  '/home_screen':(context) => const home_screen.HomeScreen(),
  '/home_screen_loved_one': (context) => const home_loved_one_screen.HomeScreen(),
  '/video_screen':(context)=>const video_screen.Video(),
};