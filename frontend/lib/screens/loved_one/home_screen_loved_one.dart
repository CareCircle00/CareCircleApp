import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sms/flutter_sms.dart';

import '../../global.dart' as global;
import '../../helper/activity.dart' as activity;

List moods = [
  'Unhappy',
  'Down',
  'Okay',
  'Happy',
  'Very Happy',
];

List membersList = [];
List<String> memberNumbers = [];
List all_contacts = [];

void updateLastOnline(){
  HttpsCallable uplo = FirebaseFunctions.instance.httpsCallable('circle-updateLastOnline');
  uplo.call(<String,dynamic>{
    'cid': global.cid,
    'timestamp':DateTime.now().toString()
  }).then((resp)=>{
    print(resp),
  }).catchError((err)=>{
    print(err)
  });
}

int getPerson(dynamic contact) {
  int temp = -1;
  int i = 0;
  for (var element in all_contacts) {
    // if (element.phones!.isNotEmpty && element.phones!.elementAt(0).value ==
    //     contact["mapValue"]["fields"]["memberNumber"]["stringValue"]) {
    //   temp = i;
    // }
    if(!element.phones.isEmpty){
      // if(element.phones[0] == contact["mapValue"]["fields"]["memberNumber"]["stringValue"]) {
      if(element.phones[0] == contact) {
        temp = i;
        break;
      }
    }
    // print(element.displayName);
    // print(element.phones[0]);
    ++i;
  }
  return temp;
}

void getCurrMood()async{
  HttpsCallable getMood = FirebaseFunctions.instance.httpsCallable('circle-getCurrentMood');
  getMood.call(<String,dynamic>{
    'cid':global.cid
  }).then((resp)=>{
    print(resp)
  });
}

void sending_SMS(String msg, List<String> list_receipents) async {
  String send_result = await sendSMS(message: msg, recipients: list_receipents)
      .catchError((err) {
    print(err);
  });
  print(send_result);
}

void handlePressed(String btn){
  print(btn);
  if(btn == 'Notify to Call Me'){
    sending_SMS('Call Me', memberNumbers);
}
}

Future<dynamic> getCircleFromCID() async{
  dynamic rval = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  String phno = user!.phoneNumber!;
  HttpsCallable getCircle = FirebaseFunctions.instance.httpsCallable('circle-getCircle');
  await getCircle.call(<String,dynamic>{
    'circleID': global.cid,
  }).then((response)=>{
    rval = response.data,
  });
  return rval;
}

void _callNumber(String number) async{
  // const number = '9148009365'; //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
}


Future<List<dynamic>> getCircActions()async{
  List<dynamic> ret = [];
  HttpsCallable getAct = FirebaseFunctions.instance.httpsCallable('actions-getCircleActions');
  await getAct.call(<String,dynamic>{
    'cid': global.cid,
  }).then((resp)=>{
    // ret = resp.data[""],
    // print('resp:${resp.data}'),
    ret = resp.data['actions']
  });
  return ret;
}

Future<String> checkUser()async{
  final user = FirebaseAuth.instance.currentUser!;
  final uid = user.uid;
  String rval = '';
  HttpsCallable chuser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
  await chuser.call(<String,dynamic>{
    'uid':uid
  }).then((resp)=>{
    if(resp.data['user']['circle']!=null){
      rval = resp.data['user']['circle'],
    }
  });
  return rval;
}

Future<void> setMood(int m)async{
  HttpsCallable chmood = FirebaseFunctions.instance.httpsCallable('circle-changeMood');
  chmood.call(<String,dynamic>{
    'mood':m,
    'circleID': global.cid,
    'timestamp': DateTime.now().toString(),
  }).then((resp)=>{
  });
}

class Head extends StatelessWidget {
  const Head({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.fromLTRB(0,10*height/740,0,8*height/740),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20*height/740),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.2,
            color: Colors.grey,
          )
        )
      ),
      child: Stack(
        alignment: Alignment.center,
        children:[
        ],
      ),
    );
  }
}


class LovedOneHomeScreen extends StatefulWidget {
  const LovedOneHomeScreen({Key? key}) : super(key: key);

  @override
  State<LovedOneHomeScreen> createState() => _LovedOneHomeScreenState();
}

class _LovedOneHomeScreenState extends State<LovedOneHomeScreen> {
  @override
  // String cid = '';
  bool isLoading3 = true;
  bool isLoadingContacts = true;
  List<String> actsList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateLastOnline();
    void getAllContacts() async{
      List get_all_contacts = await FastContacts.allContacts;
      if(mounted){
        setState(() {
          // contacts = getContacts;
          all_contacts = get_all_contacts;
          isLoadingContacts = false;
          // print(contacts[0].phones!.elementAt(0).value);
          // print(contacts[0].displayName![0]);
        });
      }
    }
    getCircActions().then((resp)=>{
      for(int i=0; i<resp.length; ++i){
        actsList.add(resp[i]['_fieldsProto']['name']['stringValue']),
      },
      getAllContacts(),
      
      getCircleFromCID().then((value) {
        membersList = value['circle']['members'];
        print('here: ${membersList}');
        for(int i =0;i<membersList.length; ++i){
          memberNumbers.add(membersList[i]['memberNumber']);
        }

        setState(() {
          // print(membersList);
          isLoading3 = false;
        });
      })
    });
  }
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            const Head(),
            // actsList.length%2==0?ListView.builder(
            //     shrinkWrap: true,
            //     itemCount: actsList.length,
            //     itemBuilder: (context,index){
            //       if(index%2!=0) {
            //         return const SizedBox();
            //       }else{
            //         return Row(
            //           children: [
            //             Expanded(
            //               child: Container(
            //                 margin: const EdgeInsets.fromLTRB(10,10,10,10),
            //                 height: height*140/740,
            //                 child: ElevatedButton(
            //                     onPressed: () {
            //                       handlePressed(actsList[index]);
            //                     },
            //                     child: Text(
            //                       actsList[index],
            //                       textAlign: TextAlign.center,
            //                       style: TextStyle(
            //                           fontSize: 18*width/360,
            //                           color: Colors.white
            //                       ),
            //                     )
            //                 ),
            //               ),
            //             ),
            //             Expanded(
            //               child: Container(
            //                 margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //                 // padding: EdgeInsets.only(left: 8.0),
            //                 height: 140*height/740,
            //                 child: ElevatedButton(
            //                     onPressed: () {
            //                       handlePressed(actsList[index+1]);
            //                     },
            //                     child:Text(
            //                       actsList[index+1],
            //                       style: TextStyle(
            //                           fontSize: 18*width/360,
            //                           color: Colors.white
            //                       ),
            //                     )
            //                 ),
            //               ),
            //             )
            //           ],
            //         );
            //       }
            //     }
            // ):ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: actsList.length,
            //   itemBuilder: (context,index){
            //     if(index%2!=0 && index!= actsList.length-1) {
            //       return const SizedBox();
            //     }else if(index!= actsList.length-1){
            //       return Row(
            //         children: [
            //           Expanded(
            //             child: Container(
            //               margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //               height: 140*height/740,
            //               child: ElevatedButton(
            //                   onPressed: () {
            //                     handlePressed(actsList[index]);
            //                   },
            //                   style: ElevatedButton.styleFrom(
            //                     backgroundColor: Colors.lightBlueAccent,
            //                   ),
            //                   child: Text(
            //                     actsList[index],
            //                     textAlign: TextAlign.center,
            //                     style: TextStyle(
            //                         fontSize: 18*width/360,
            //                         color: Colors.black
            //                     ),
            //                   )
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Container(
            //               margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //               // padding: EdgeInsets.only(left: 8.0),
            //               height: 140*height/740,
            //               child: ElevatedButton(
            //                   style: ElevatedButton.styleFrom(
            //                     // backgroundColor: Colors.pinkAccent,
            //                   ),
            //                   onPressed: () {
            //                     handlePressed(actsList[index+1]);
            //                     // HttpsCallable checkSetup = FirebaseFunctions.instance.httpsCallable('circle-changeMood');
            //                     // checkSetup.call(<String,dynamic>{
            //                     //   'mood':3,
            //                     // });
            //                   },
            //                   child:Text(
            //                     actsList[index+1],
            //                     textAlign: TextAlign.center,
            //                     style: TextStyle(
            //                       fontSize: 18*width/360,
            //                       color: Colors.black,
            //                     ),
            //                   )
            //               ),
            //             ),
            //           )
            //         ],
            //       );
            //     }else{
            //       return Container(
            //         margin: EdgeInsets.fromLTRB(10*width/360, 10*height/740, 10*width/360, 0*height/740),
            //         height: 140*height/740,
            //         child: ElevatedButton(
            //             onPressed: () {
            //               handlePressed(actsList[index]);},
            //             style: ElevatedButton.styleFrom(
            //               shape: CircleBorder(),
            //               backgroundColor: Colors.blue,
            //               // backgroundColor: Colors.lightGreenAccent,
            //             ),
            //             child:Text(
            //               actsList[index],
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   fontSize: 18*width/360,
            //                   color: Colors.white
            //               ),
            //             )
            //         ),
            //       );
            //     }
            //   },
            // ),

            Container(
              padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 150*height/740,
                  // crossAxisSpacing: 7,
                  // mainAxisSpacing: 7,
                ),
                itemCount: membersList.length,
                itemBuilder: (BuildContext context, index){
                  int temp1 = getPerson(membersList[index]['memberNumber']);
                  late Future<Uint8List?> _imageFuture1;
                  if(temp1!=-1){
                    _imageFuture1 = FastContacts.getContactImage(all_contacts[temp1].id);
                  }
                  return TextButton(
                      onPressed: () {
                        _callNumber(membersList[index]['memberNumber']);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                      child: Container(
                      // margin: const EdgeInsets.fromLTRB(10,10,10,10),
                      // height: height*140/740,
                      child: Column(
                        children: [
                          temp1==-1? CircleAvatar(
                          radius: 30*width/360,
                          backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
                          // child: Text(
                          //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
                          //     style: TextStyle(
                          //         fontSize: 25*width/360
                          //     )
                          // ),
                          ):FutureBuilder<Uint8List?>(
                            future: _imageFuture1,
                            builder: (context, snapshot) => Container(
                            width: 60*width/360,
                            height: 60*width/360,
                            child: snapshot.hasData?
                            CircleAvatar(
                            backgroundImage: MemoryImage(snapshot.data!),
                            radius:30*width/360,
                          ) :
                            CircleAvatar(
                              radius: 30*width/360,
                              child: Text(
                                  all_contacts[temp1!].displayName[0],
                                  style: TextStyle(
                                      fontSize: 24*width/360
                                  )
                              ),
                            ),
                            ),
                          ),

                          Text(
                            temp1==-1? 'Call ${membersList[index]['memberNumber']}' : 'Call ${all_contacts[temp1].displayName}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14*width/360,
                                color: Colors.black
                            ),
                          )

                      ],
                    ),
                  )
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
              // padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 120*height/740,
                  // crossAxisSpacing: 7,
                  // mainAxisSpacing: 7,
                ),
                itemCount: actsList.length,
                itemBuilder: (BuildContext context, index){

                  return Container(
                    // margin: EdgeInsets.fromLTRB(20*width/460,20*width/460,20*width/460,20*width/460),
                    // height: height*140/740,
                    child: ElevatedButton(
                        onPressed: () {
                          handlePressed(actsList[index]);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                        ),
                        child: Text(
                          actsList[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14*width/360,
                              color: Colors.white
                          ),
                        )
                    ),
                  );
                },
              ),
            ),
            // membersList.length%2==0?ListView.builder(
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemCount: membersList.length,
            //     itemBuilder: (context,index){
            //       if(index%2!=0) {
            //         return const SizedBox();
            //       }else{
            //         int temp1 = getPerson(membersList[index]['memberNumber']);
            //         int temp2 = getPerson(membersList[index+1]['memberNumber']);
            //         late Future<Uint8List?> _imageFuture1;
            //         late Future<Uint8List?> _imageFuture2;
            //         if(temp1!=-1){
            //           _imageFuture1 = FastContacts.getContactImage(all_contacts[temp1].id);
            //         }
            //         if(temp2!=-1){
            //           _imageFuture2 = FastContacts.getContactImage(all_contacts[temp2].id);
            //         }
            //         return Row(
            //           children: [
            //             Expanded(
            //               child: Container(
            //                 margin: const EdgeInsets.fromLTRB(10,10,10,10),
            //                 height: height*140/740,
            //                 child: Column(
            //                   children: [
            //                     temp1==-1? CircleAvatar(
            //                     radius: 30*width/360,
            //                     backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
            //                     // child: Text(
            //                     //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
            //                     //     style: TextStyle(
            //                     //         fontSize: 25*width/360
            //                     //     )
            //                     // ),
            //                     ):FutureBuilder<Uint8List?>(
            //                       future: _imageFuture1,
            //                       builder: (context, snapshot) => Container(
            //                       width: 60*width/360,
            //                       height: 60*width/360,
            //                       child: snapshot.hasData?
            //                       CircleAvatar(
            //                       backgroundImage: MemoryImage(snapshot.data!),
            //                       radius:30*width/360,
            //                     ) :
            //                       CircleAvatar(
            //                         radius: 30*width/360,
            //                         child: Text(
            //                             all_contacts[temp1!].displayName[0],
            //                             style: TextStyle(
            //                                 fontSize: 24*width/360
            //                             )
            //                         ),
            //                       ),
            //                       ),
            //                     ),
            //                     TextButton(
            //                         onPressed: () {
            //                           _callNumber(membersList[index]['memberNumber']);
            //                         },
            //                         style: ElevatedButton.styleFrom(
            //                           shape: CircleBorder(),
            //                         ),
            //                         child: Text(
            //                           temp1==-1? 'Call ${membersList[index]['memberNumber']}' : 'Call ${all_contacts[temp1].displayName}',
            //                           textAlign: TextAlign.center,
            //                           style: TextStyle(
            //                               fontSize: 18*width/360,
            //                               color: Colors.black
            //                           ),
            //                         )
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //             Expanded(
            //               child: Container(
            //                 margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //                 // padding: EdgeInsets.only(left: 8.0),
            //                 height: 140*height/740,
            //                 child: Column(
            //                   children: [
            //                     temp2==-1? CircleAvatar(
            //                       radius: 30*width/360,
            //                       backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
            //                       // child: Text(
            //                       //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
            //                       //     style: TextStyle(
            //                       //         fontSize: 25*width/360
            //                       //     )
            //                       // ),
            //                     ):FutureBuilder<Uint8List?>(
            //                       future: _imageFuture2,
            //                       builder: (context, snapshot) => Container(
            //                         width: 60*width/360,
            //                         height: 60*width/360,
            //                         child: snapshot.hasData?
            //                         CircleAvatar(
            //                           backgroundImage: MemoryImage(snapshot.data!),
            //                           radius:30*width/360,
            //                         ) :
            //                         CircleAvatar(
            //                           radius: 30*width/360,
            //                           child: Text(
            //                               all_contacts[temp2!].displayName[0],
            //                               style: TextStyle(
            //                                   fontSize: 24*width/360
            //                               )
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                     TextButton(
            //                         onPressed: () {
            //                           _callNumber(membersList[index+1]['memberNumber']);
            //                         },
            //                         style: ElevatedButton.styleFrom(
            //                           shape: CircleBorder(),
            //                         ),
            //                         child:Text(
            //                           temp2==-1? 'Call ${membersList[index+1]['memberNumber']}' : 'Call ${all_contacts[temp2].displayName}',
            //                           // isLoadingContacts == true?'Call ${membersList[index+1]['memberNumber']}':temp2!=-1?  all_contacts[temp2]: membersList[index+1]['memberNumber'],
            //                           textAlign: TextAlign.center,
            //                           style: TextStyle(
            //                               fontSize: 18*width/360,
            //                               color: Colors.black
            //                           ),
            //                         )
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             )
            //           ],
            //         );
            //       }
            //     }
            // ):ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: membersList.length,
            //   itemBuilder: (context,index){
            //     if(index%2!=0 && index!= membersList.length-1) {
            //       return const SizedBox();
            //     }else if(index%2==0&&index!= membersList.length-1){
            //       int temp1 = getPerson(membersList[index]['memberNumber']);
            //       int temp2 = getPerson(membersList[index+1]['memberNumber']);
            //       late Future<Uint8List?> _imageFuture1;
            //       late Future<Uint8List?> _imageFuture2;
            //       if(temp1!=-1){
            //         _imageFuture1 = FastContacts.getContactImage(all_contacts[temp1].id);
            //       }
            //       if(temp2!=-1){
            //         _imageFuture2 = FastContacts.getContactImage(all_contacts[temp2].id);
            //       }
            //       return Row(
            //         children: [
            //           Expanded(
            //             child: Container(
            //               margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //               height: 140*height/740,
            //               child: Column(
            //                 children: [
            //                   temp1==-1? CircleAvatar(
            //                     radius: 30*width/360,
            //                     backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
            //                     // child: Text(
            //                     //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
            //                     //     style: TextStyle(
            //                     //         fontSize: 25*width/360
            //                     //     )
            //                     // ),
            //                   ):FutureBuilder<Uint8List?>(
            //                     future: _imageFuture1,
            //                     builder: (context, snapshot) => Container(
            //                       width: 60*width/360,
            //                       height: 60*width/360,
            //                       child: snapshot.hasData?
            //                       CircleAvatar(
            //                         backgroundImage: MemoryImage(snapshot.data!),
            //                         radius:30*width/360,
            //                       ) :
            //                       CircleAvatar(
            //                         radius: 30*width/360,
            //                         child: Text(
            //                             all_contacts[temp1!].displayName[0],
            //                             style: TextStyle(
            //                                 fontSize: 24*width/360
            //                             )
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   TextButton(
            //                       onPressed: () {
            //                         _callNumber(membersList[index]['memberNumber']);
            //                       },
            //                       style: ElevatedButton.styleFrom(
            //                         // backgroundColor: Colors.lightBlueAccent,
            //                         shape: CircleBorder(),
            //                       ),
            //                       child: Text(
            //                         temp1==-1? 'Call ${membersList[index]['memberNumber']}' : 'Call ${all_contacts[temp1].displayName}',
            //                         textAlign: TextAlign.center,
            //                         style: TextStyle(
            //                             fontSize: 18*width/360,
            //                             color: Colors.black
            //                         ),
            //                       )
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Container(
            //               margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
            //               // padding: EdgeInsets.only(left: 8.0),
            //               height: 140*height/740,
            //               child: Column(
            //                 children: [
            //                   temp2==-1? CircleAvatar(
            //                     radius: 30*width/360,
            //                     backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
            //                     // child: Text(
            //                     //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
            //                     //     style: TextStyle(
            //                     //         fontSize: 25*width/360
            //                     //     )
            //                     // ),
            //                   ):FutureBuilder<Uint8List?>(
            //                     future: _imageFuture2,
            //                     builder: (context, snapshot) => Container(
            //                       width: 60*width/360,
            //                       height: 60*width/360,
            //                       child: snapshot.hasData?
            //                       CircleAvatar(
            //                         backgroundImage: MemoryImage(snapshot.data!),
            //                         radius:30*width/360,
            //                       ) :
            //                       CircleAvatar(
            //                         radius: 30*width/360,
            //                         child: Text(
            //                             all_contacts[temp2!].displayName[0],
            //                             style: TextStyle(
            //                                 fontSize: 24*width/360
            //                             )
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   TextButton(
            //                       style: ElevatedButton.styleFrom(
            //                         // backgroundColor: Colors.pinkAccent,
            //                           shape: CircleBorder()
            //                       ),
            //                       onPressed: () {
            //                         _callNumber(membersList[index+1]['memberNumber']);
            //                         // HttpsCallable checkSetup = FirebaseFunctions.instance.httpsCallable('circle-changeMood');
            //                         // checkSetup.call(<String,dynamic>{
            //                         //   'mood':3,
            //                         // });
            //                       },
            //                       child:Text(
            //                         temp2==-1? 'Call ${membersList[index+1]['memberNumber']}' : 'Call ${all_contacts[temp2].displayName}',
            //                         textAlign: TextAlign.center,
            //                         style: TextStyle(
            //                             fontSize: 18*width/360,
            //                             color: Colors.black
            //                         ),
            //                       )
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           )
            //         ],
            //       );
            //     }
            //     else{
            //       int temp3 = getPerson(membersList[index]['memberNumber']);
            //       late Future<Uint8List?> _imageFuture3;
            //       if(temp3!=-1){
            //         _imageFuture3 = FastContacts.getContactImage(all_contacts[temp3].id);
            //       }
            //       return Container(
            //         margin: EdgeInsets.fromLTRB(10*width/360, 10*height/740, 10*width/360, 0*height/740),
            //         // height: 140*height/740,
            //         child: Column(
            //           children: [
            //             temp3==-1? CircleAvatar(
            //               radius: 30*width/360,
            //               backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
            //               // child: Text(
            //               //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
            //               //     style: TextStyle(
            //               //         fontSize: 25*width/360
            //               //     )
            //               // ),
            //             ):FutureBuilder<Uint8List?>(
            //               future: _imageFuture3,
            //               builder: (context, snapshot) => Container(
            //                 width: 60*width/360,
            //                 height: 60*width/360,
            //                 child: snapshot.hasData?
            //                 CircleAvatar(
            //                   backgroundImage: MemoryImage(snapshot.data!),
            //                   radius:30*width/360,
            //                 ) :
            //                 CircleAvatar(
            //                   radius: 30*width/360,
            //                   child: Text(
            //                       all_contacts[temp3!].displayName[0],
            //                       style: TextStyle(
            //                           fontSize: 24*width/360
            //                       )
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             TextButton(
            //                 onPressed: () {
            //                   _callNumber(membersList[index]['memberNumber']);
            //                 },
            //                 style: TextButton.styleFrom(
            //                   // backgroundColor: Colors.lightGreenAccent,
            //                   // backgroundColor: Colors.lightBlueAccent,
            //                 ),
            //                 child:Text(
            //                   temp3==-1? 'Call ${membersList[index]['memberNumber']}' : 'Call ${all_contacts[temp3].displayName}',
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                       fontSize: 18*width/360,
            //                       color: Colors.black
            //                   ),
            //                 )
            //             ),
            //           ],
            //         ),
            //       );
            //     }
            //   },
            // ),
            Container(
                margin: EdgeInsets.fromLTRB(20*width/360, 25*height/720, 20*width/360, 0),
                padding: EdgeInsets.fromLTRB(0,20*height/720,0,0),
                decoration: BoxDecoration(
                  border: Border(
                    top:BorderSide(
                      width: 1,
                      color: Colors.grey
                    )
                  )
                ),
                child: Text(
                  'My Current Mood',
                  style: TextStyle(
                    fontSize: 20*width/360,
                    color: Colors.blueGrey
                  ),
                )
            ),
            isLoading3 == true? SizedBox():Container(
              alignment: Alignment.center,
              child:
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Circle').doc(global.cid).collection('mood').orderBy('timestamp',descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const SizedBox();
                    }
                    else if(snapshot.connectionState == ConnectionState.active){
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          // itemCount: snapshot.data!.size,
                          // itemCount: snapshot.data!.size==0? 0:1,
                          itemCount: 1,
                          itemBuilder:(BuildContext context, int index){
                            // print('here:${snapshot.data!.docs.elementAt(index)['mood']}');
                            int temp=-1;
                            if(snapshot.data!.size!=0){
                              temp = snapshot.data!.docs.elementAt(index)['mood'];
                            }
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextButton(
                                      onPressed: (){
                                        // setState(() {
                                        //   isLoading3 = true;
                                        // });
                                        setMood(5).then((resp)=>{
                                          activity.addActivity(global.cid,'Mood Changed to ${moods[4]}').then((resp2)=>{
                                            print(moods[4])
                                          }),
                                          // setState((){
                                          //   isLoading3=false;
                                          // })
                                        });
                                      },
                                      // child: Text(parser.info('smiley').code)
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: temp == 5? 80*width/360: 50*width/360,
                                            height: temp ==5? 80*width/360: 50*width/360,
                                            child: Text(
                                              '😀',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: temp==5?70*width/360:40*width/360,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50*width/360,
                                            height: 50*width/360,
                                            child: Text(
                                              moods[4],
                                              textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: temp==5?18*width/360:14*width/360
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  TextButton(
                                      onPressed: (){
                                        // setState(() {
                                        //   isLoading3 = true;
                                        // });
                                        setMood(4).then((resp)=>{
                                          activity.addActivity(global.cid,'Mood Changed to ${moods[3]}').then((resp2)=>{
                                            print(moods[3])
                                          }),
                                          // setState((){
                                          //   isLoading3=false;
                                          // })
                                        });
                                      },
                                      // child: Text(parser.info('smiley').code)
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: temp == 4? 80*width/360: 50*width/360,
                                            height: temp ==4? 80*width/360: 50*width/360,
                                            child: Text(
                                              '☺',
                                              style: TextStyle(
                                                fontSize: temp==4?70*width/360:40*width/360,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50*width/360,
                                            height: 50*width/360,
                                            child: Text(
                                              moods[3],
                                              textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: temp==4?18*width/360:14*width/360
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  TextButton(
                                      onPressed: (){
                                        // setState(() {
                                        //   isLoading3 = true;
                                        // });
                                        setMood(3).then((resp)=>{
                                          activity.addActivity(global.cid,'Mood Changed to ${moods[2]}').then((resp2)=>{
                                            print(moods[2])
                                          }),
                                          // setState((){
                                          //   isLoading3=false;
                                          // })
                                        });
                                      },
                                      // child: Text(parser.info('smiley').code)
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: temp == 3? 80*width/360: 50*width/360,
                                            height: temp ==3? 80*width/360: 50*width/360,
                                            child: Text(
                                              '🙂',
                                              style: TextStyle(
                                                fontSize: temp==3?70*width/360:40*width/360,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50*width/360,
                                            height: 50*width/360,
                                            child: Text(
                                              moods[2],
                                              textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: temp==3?18*width/360:14*width/360
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  TextButton(
                                      onPressed: (){
                                        // setState(() {
                                        //   isLoading3 = true;
                                        // });
                                        setMood(2).then((resp)=>{
                                          activity.addActivity(global.cid,'Mood Changed to ${moods[1]}').then((resp2)=>{
                                            print(moods[1])
                                          }),
                                          // setState((){
                                          //   isLoading3=false;
                                          // })
                                        });
                                      },
                                      // child: Text(parser.info('smiley').code)
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: temp == 2? 80*width/360: 50*width/360,
                                            height: temp ==2? 80*width/360: 50*width/360,
                                            child: Text(
                                              '🙁',
                                              style: TextStyle(
                                                fontSize: temp==2?70*width/360:40*width/360,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50*width/360,
                                            height: 50*width/360,
                                            child: Text(
                                              moods[1],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: temp==2?20*width/360:14*width/360
                                              )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  TextButton(
                                      onPressed: (){
                                        // setState(() {
                                        //   isLoading3 = true;
                                        // });
                                        setMood(1).then((resp)=>{
                                          activity.addActivity(global.cid,'Mood Changed to ${moods[0]}').then((resp2)=>{
                                            print(moods[0])
                                          }),
                                          // setState((){
                                          //   isLoading3=false;
                                          // })
                                        });
                                      },
                                      // child: Text(parser.info('smiley').code)
                                      child : Column(
                                        children: [
                                          SizedBox(
                                            width: temp == 1? 80*width/360: 50*width/360,
                                            height: temp ==1? 80*width/360: 50*width/360,
                                            child: Text(
                                              '😞',
                                              style: TextStyle(
                                                fontSize: temp==1?70*width/360:40*width/360,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50*width/360,
                                            height: 50*width/360,
                                            child: Text(
                                              moods[0],
                                              textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: temp==1?18*width/360:14*width/360
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                ]
                            );
                          }
                      );
                    }
                    else{
                      return const SizedBox();
                    }
                  }
              ),
            ),
          ]
      )
    );
  }
}
