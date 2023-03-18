import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './home_screen_loved_one.dart' as home_screen;
import '../care_giver/circle_screen.dart' as circle_screen;
import '../care_giver/coming_soon_screen.dart' as coming_soon_screen;
import '../care_giver/chat_screen.dart' as chat_screen;
import '../../global.dart' as global;

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
      home_screen.LovedOneHomeScreen(),
      // coming_soon_screen.ComingSoon(),
      circle_screen.AddLovedOne(),
      // chat_screen.ChatScreen(),
      // coming_soon_screen.ComingSoon(),
    ];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          title: Text('Care Circle')
      ),
      body: pages.elementAt(_HomeScreenState.currentIndex),
      drawer : Drawer(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(5*width/360,5*height/740,5*width/360,0*height/740),
              children: [
                Container(
                  height: 80*height/740,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  // color: Colors.blue,
                  // decoration: BoxDecoration(
                  //
                  // ),
                  child: DrawerHeader(
                      padding: EdgeInsets.fromLTRB(10*width/360, 10*height/740, 0, 0),
                      margin: EdgeInsets.zero,
                      child: Text(
                          'Care Circle',
                          style: TextStyle(
                            fontSize: 20*width/360,
                            // color: Colors.grey,
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.w600,
                          )
                      )
                  ),
                ),
                ListTile(
                  title: const Text('Home'),
                  onTap: (){
                    setState(() {
                      _HomeScreenState.currentIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('My Circles'),
                  onTap: (){
                    setState(() {
                      _HomeScreenState.currentIndex = 1;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Signout'),
                  onTap: (){
                    setState(() {
                      final auth = FirebaseAuth.instance;
                      auth.signOut().then((value) => {
                        Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false)
                      });
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Delete Account',style: TextStyle(color: Colors.red),),
                  onTap: (){
                    setState(() {
                      final auth = FirebaseAuth.instance;
                      HttpsCallable delAct = FirebaseFunctions.instance.httpsCallable('activity-delActivity');
                      HttpsCallable delCirc = FirebaseFunctions.instance.httpsCallable('circle-delCircle');
                      HttpsCallable delUser = FirebaseFunctions.instance.httpsCallable('user-delUser');
                      delAct.call(<String,dynamic>{
                        'cid': global.cid
                      }).then((resp)=>{
                        delCirc.call(<String,dynamic>{
                          'cid':global.cid
                        }).then((resp2)=>{
                          delUser.call().then((resp3)=>{
                            auth.signOut().then((value){
                              global.cid = '';
                              Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false);
                            })
                          })
                        })
                      });
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

        )
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_filled),
      //       label: 'Home',
      //     ),
      //     // BottomNavigationBarItem(
      //     //   // icon: Icon(IconData(0xf3e1)),
      //     //     icon:Icon(Icons.notifications_none_outlined),
      //     //     label:'Alerts'
      //     // ),
      //     BottomNavigationBarItem(
      //       // icon: Icon(Icons.cloud_circle_outlined),
      //         icon: Icon(Icons.lightbulb_circle_outlined),
      //         label:'My Circle'
      //     ),
      //     // BottomNavigationBarItem(
      //     //     icon: Icon(Icons.chat_bubble_outline),
      //     //     label:'Chats'
      //     // ),
      //     // BottomNavigationBarItem(
      //     //     icon: Icon(Icons.settings),
      //     //     label:'Settings'
      //     // )
      //   ],
      //   currentIndex: _HomeScreenState.currentIndex,
      //   onTap: (int index){
      //     setState(() {
      //       _HomeScreenState.currentIndex = index;
      //     });
      //   },
      // ),
    );
  }
}