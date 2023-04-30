import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './home_screen.dart' as home_screen;
import './circle_screen.dart' as circle_screen;
import '../../global.dart' as global;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


// Future<String> getUserInfo()async{
//   String cid = '';
//   HttpsCallable getInfo = FirebaseFunctions.instance.httpsCallable('user-getUserInfo');
//   await getInfo.call(<String,dynamic>{
//   }).then((resp)=>{
//     cid = resp.data['circle']
//   });
//   return cid;
// }




class _HomeScreenState extends State<HomeScreen> {
  static int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    const List<Widget> pages = [
      home_screen.Home(),
      circle_screen.AddLovedOne(),
    ];

    List titles = [
      'Home',
      'My Circle'
    ];

    void signout() async{
      final auth = FirebaseAuth.instance;
      await auth.signOut().then((value) {
        Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_HomeScreenState.currentIndex]),
        actions: [
          _HomeScreenState.currentIndex==1?
              TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/contact_book_screen');
                  },
                  child: Text(
                      'Invite',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16*width/360,
                        fontWeight: FontWeight.w500,
                      )
                  )
              ): SizedBox()
        ],
      ),
      body: pages.elementAt(_HomeScreenState.currentIndex),
      drawer: Drawer(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
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
                setState((){
                  signout();
                });
                // Navigator.pop(context);
              },
            ),ListTile(
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
        )
      )
    );
  }
}