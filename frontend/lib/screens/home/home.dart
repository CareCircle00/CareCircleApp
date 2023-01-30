import 'package:flutter/material.dart';

import './home_screen.dart' as home_screen;
import './circle_screen.dart' as circle_screen;
import './coming_soon_screen.dart' as coming_soon_screen;
import './chat_screen.dart' as chat_screen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    const List<Widget> pages = [
      home_screen.Home(),
      // coming_soon_screen.ComingSoon(),
      circle_screen.AddLovedOne(),
      // chat_screen.ChatScreen(),
      // coming_soon_screen.ComingSoon(),
    ];
    return Scaffold(
      body: pages.elementAt(_HomeScreenState.currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   // icon: Icon(IconData(0xf3e1)),
          //     icon:Icon(Icons.notifications_none_outlined),
          //     label:'Alerts'
          // ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.cloud_circle_outlined),
              icon: Icon(Icons.lightbulb_circle_outlined),
              label:'My Circle'
          ),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.chat_bubble_outline),
          //     label:'Chats'
          // ),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.settings),
          //     label:'Settings'
          // )
        ],
        currentIndex: _HomeScreenState.currentIndex,
        onTap: (int index){
          setState(() {
            _HomeScreenState.currentIndex = index;
          });
        },
      ),
    );
  }
}