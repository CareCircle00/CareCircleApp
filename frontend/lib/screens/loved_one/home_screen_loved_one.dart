import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:string_2_icon/string_2_icon.dart';

import '../../global.dart' as global;
import '../../helper/activity.dart' as activity;

import 'package:circular_menu/circular_menu.dart';

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
    // print(resp),
  }).catchError((err)=>{
    print(err)
  });
}

int getPerson(dynamic contact) {
  int temp = -1;
  int i = 0;
  for (var element in all_contacts) {
    if(!element.phones.isEmpty){
      if(element.phones[0] == contact) {
        temp = i;
        break;
      }
    }
    ++i;
  }
  return temp;
}

// void getCurrMood()async{
//   HttpsCallable getMood = FirebaseFunctions.instance.httpsCallable('circle-getCurrentMood');
//   getMood.call(<String,dynamic>{
//     'cid':global.cid
//   }).then((resp)=>{
//     print(resp)
//   });
// }

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
    sending_SMS('Hey guys, I need your help, can you call me asap! Thank you!', memberNumbers);
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

// Future<String> checkUser()async{
//   final user = FirebaseAuth.instance.currentUser!;
//   final uid = user.uid;
//   String rval = '';
//   HttpsCallable chuser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
//   await chuser.call(<String,dynamic>{
//     'uid':uid
//   }).then((resp)=>{
//     if(resp.data['user']['circle']!=null){
//       rval = resp.data['user']['circle'],
//     }
//   });
//   return rval;
// }

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
      // decoration: const BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       width: 0.2,
      //       color: Colors.grey,
      //     )
      //   )
      // ),
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
  bool isLoading3 = true;
  bool isLoadingContacts = true;
  List<String> actsList = [];

  final flutterReactiveBle = FlutterReactiveBle();

  void readingData(){
    print('starting reading data function');
    final characteristic = QualifiedCharacteristic(serviceId: Uuid.parse('75c276c3-8f97-20bc-a143-b354244886d4'), characteristicId: Uuid.parse('d3d46a35-4394-e9aa-5a43-e7921120aaed'), deviceId: 'FB:8B:B6:AC:D3:C4');
    flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
      print('look here: $data');
      // code to handle incoming data
    }, onError: (dynamic error) {
      print('error connecting to device');
      // code to handle errors
    });
  }


  void scanBT(){
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      print('look here ${device}');
      //code for handling results
    }, onError: (error) {
      //code for handling error
    });
  }

  void connectBT(){
    flutterReactiveBle.connectToDevice(
      id: 'FB:8B:B6:AC:D3:C4',
      servicesWithCharacteristicsToDiscover: {},
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {
      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
    });
  }

  void writeBT()async{
    final characteristic = QualifiedCharacteristic(serviceId: Uuid.parse('75c276c3-8f97-20bc-a143-b354244886d4'), characteristicId: Uuid.parse('6acf4f08-cc9d-d495-6b41-aa7e60c4e8a6'), deviceId: 'FB:8B:B6:AC:D3:C4');
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: [0x03]);
  }

  void readBT() async{
    // final characteristic = QualifiedCharacteristic(serviceId: Uuid.parse('75c276c3-8f97-20bc-a143-b354244886d4'), characteristicId: Uuid.parse('d3d46a35-4394-e9aa-5a43-e7921120aaed'), deviceId: 'FB:8B:B6:AC:D3:C4');
    // final response = await flutterReactiveBle.readCharacteristic(characteristic);
    // print(response);
  }

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
        for(int i =0;i<membersList.length; ++i){
          memberNumbers.add(membersList[i]['memberNumber']);
        }

        setState(() {
          // print(membersList);
          isLoading3 = false;
        });
      })
    });
    // scanBT();
    // writeBT();
    // _connectToDevice();
    readingData();
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
            Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Circle').doc(global.cid).collection('Members').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const SizedBox();
                    }
                    else if(snapshot.connectionState == ConnectionState.active){
                      // return ListView.builder(
                      //     shrinkWrap: true,
                      //     physics: NeverScrollableScrollPhysics(),
                      //     itemCount: snapshot.data!.size,
                      //     itemBuilder: (BuildContext context,int index){
                      //       int ret = getPerson(snapshot.data!.docs.elementAt(index)["memberNumber"]);
                            return  Container(
                                margin: EdgeInsets.fromLTRB(0.03*width, 0, 0.03*width, 0.01*height),
                                padding: EdgeInsets.fromLTRB(0,0,0,0.01*height),
                                // decoration: const BoxDecoration(
                                //   border: Border(
                                //     bottom: BorderSide(
                                //       width: 0.5,
                                //       color: Colors.grey,
                                //     ),
                                //   ),
                                // ),
                                child: SizedBox(
                                  child:
                                  GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        // crossAxisCount: membersList.isNotEmpty&& membersList.length<2?membersList.length:2,
                                        crossAxisCount: snapshot.data!.size!=0&& snapshot.data!.size<2?snapshot.data!.size:2,
                                        // crossAxisCount: 2,
                                        mainAxisExtent: 140*height/740,
                                        // crossAxisSpacing: 7,
                                        // mainAxisSpacing: 7,
                                      ),
                                      itemCount: snapshot.data!.size,
                                      itemBuilder: (BuildContext context, index){
                                        int temp1 = getPerson(snapshot.data!.docs.elementAt(index)["memberNumber"]);
                                        late Future<Uint8List?> _imageFuture1;
                                        if(temp1!=-1){
                                          _imageFuture1 = FastContacts.getContactImage(all_contacts[temp1].id);
                                        }
                                        return TextButton(
                                            onPressed: () {
                                              _callNumber(snapshot.data!.docs.elementAt(index)["memberNumber"]);
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
                                                ):FutureBuilder<Uint8List?>(
                                                  future: _imageFuture1,
                                                  builder: (context, snapshot) => Container(
                                                  width: 100*width/360,
                                                  height: 100*width/360,
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
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(0,8,0,0),
                                                  child: Text(
                                                    temp1==-1? 'Call ${snapshot.data!.docs.elementAt(index)["memberNumber"]}' : 'Call ${all_contacts[temp1].displayName}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14*width/360,
                                                        color: Colors.black
                                                    ),
                                                  ),
                                                )

                                            ],
                                          ),
                                        )
                                        );
                                      },
                                    ),
                                )
                            );
                      //     }
                      // );
                    }else{
                      return const SizedBox();
                    }
                  }
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 150*height/740,
                ),
                itemCount: actsList.length,
                itemBuilder: (BuildContext context, index){

                  return Container(
                    // margin: EdgeInsets.fromLTRB(20*width/460,20*width/460,20*width/460,20*width/460),
                    // height: height*140/740,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0,0,0,10*height/740),
                          width: 100*width/360,
                          height: 100*width/360,
                          child: ElevatedButton(
                              onPressed: () {
                                handlePressed(actsList[index]);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Icon(
                                Icons.message,
                                size: 30*width/360
                              )
                              // child: Text(
                              //   actsList[index],
                              //   textAlign: TextAlign.center,
                              //   style: TextStyle(
                              //       fontSize: 14*width/360,
                              //       color: Colors.white
                              //   ),
                              // )
                          ),
                        ),
                        Text(
                          actsList[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14*width/360,
                              color: Colors.black,
                              // fontSize: 14*width/360,
                              // color: Colors.white
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            // Container(
            //     margin: EdgeInsets.fromLTRB(20*width/360, 25*height/720, 20*width/360, 0),
            //     padding: EdgeInsets.fromLTRB(0,20*height/720,0,0),
            //     decoration: BoxDecoration(
            //       border: Border(
            //         top:BorderSide(
            //           width: 1,
            //           color: Colors.grey
            //         )
            //       )
            //     ),
            //     child: Text(
            //       'My Current Mood',
            //       style: TextStyle(
            //         fontSize: 20*width/360,
            //         color: Colors.blueGrey
            //       ),
            //     )
            // ),
            // isLoading3 == true? SizedBox():Container(
            //   alignment: Alignment.center,
            //   child:
            //   StreamBuilder<QuerySnapshot>(
            //       stream: FirebaseFirestore.instance.collection('Circle').doc(global.cid).collection('mood').orderBy('timestamp',descending: true).snapshots(),
            //       builder: (context,snapshot){
            //         if(snapshot.connectionState == ConnectionState.waiting){
            //           return const SizedBox();
            //         }
            //         else if(snapshot.connectionState == ConnectionState.active){
            //           // double pi = 3.14;
            //           // return MoodHolder();
            //           return ListView.builder(
            //               shrinkWrap: true,
            //               physics: NeverScrollableScrollPhysics(),
            //               // itemCount: snapshot.data!.size,
            //               // itemCount: snapshot.data!.size==0? 0:1,
            //               itemCount: 1,
            //               itemBuilder:(BuildContext context, int index){
            //                 // print('here:${snapshot.data!.docs.elementAt(index)['mood']}');
            //                 int temp=-1;
            //                 if(snapshot.data!.size!=0){
            //                   temp = snapshot.data!.docs.elementAt(index)['mood'];
            //                 }
            //                 return Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: <Widget>[
            //                       TextButton(
            //                           onPressed: (){
            //                             // setState(() {
            //                             //   isLoading3 = true;
            //                             // });
            //                             setMood(5).then((resp)=>{
            //                               activity.addActivity(global.cid,'Mood Changed to ${moods[4]}').then((resp2)=>{
            //                                 print(moods[4])
            //                               }),
            //                               // setState((){
            //                               //   isLoading3=false;
            //                               // })
            //                             });
            //                           },
            //                           // child: Text(parser.info('smiley').code)
            //                           child: Column(
            //                             children: [
            //                               SizedBox(
            //                                 width: temp == 5? 80*width/360: 50*width/360,
            //                                 height: temp ==5? 80*width/360: 50*width/360,
            //                                 child: Text(
            //                                   '😀',
            //                                   textAlign: TextAlign.center,
            //                                   style: TextStyle(
            //                                     fontSize: temp==5?70*width/360:40*width/360,
            //                                   ),
            //                                 ),
            //                               ),
            //                               SizedBox(
            //                                 width: 50*width/360,
            //                                 height: 50*width/360,
            //                                 child: Text(
            //                                   moods[4],
            //                                   textAlign: TextAlign.center,
            //                                     style: TextStyle(
            //                                         fontSize: temp==5?18*width/360:14*width/360
            //                                     )
            //                                 ),
            //                               )
            //                             ],
            //                           )
            //                       ),
            //                       TextButton(
            //                           onPressed: (){
            //                             // setState(() {
            //                             //   isLoading3 = true;
            //                             // });
            //                             setMood(4).then((resp)=>{
            //                               activity.addActivity(global.cid,'Mood Changed to ${moods[3]}').then((resp2)=>{
            //                                 print(moods[3])
            //                               }),
            //                               // setState((){
            //                               //   isLoading3=false;
            //                               // })
            //                             });
            //                           },
            //                           // child: Text(parser.info('smiley').code)
            //                           child: Column(
            //                             children: [
            //                               SizedBox(
            //                                 width: temp == 4? 80*width/360: 50*width/360,
            //                                 height: temp ==4? 80*width/360: 50*width/360,
            //                                 child: Text(
            //                                   '☺',
            //                                   style: TextStyle(
            //                                     fontSize: temp==4?70*width/360:40*width/360,
            //                                   ),
            //                                 ),
            //                               ),
            //                               SizedBox(
            //                                 width: 50*width/360,
            //                                 height: 50*width/360,
            //                                 child: Text(
            //                                   moods[3],
            //                                   textAlign: TextAlign.center,
            //                                     style: TextStyle(
            //                                         fontSize: temp==4?18*width/360:14*width/360
            //                                     )
            //                                 ),
            //                               )
            //                             ],
            //                           )
            //                       ),
            //                       TextButton(
            //                           onPressed: (){
            //                             // setState(() {
            //                             //   isLoading3 = true;
            //                             // });
            //                             setMood(3).then((resp)=>{
            //                               activity.addActivity(global.cid,'Mood Changed to ${moods[2]}').then((resp2)=>{
            //                                 print(moods[2])
            //                               }),
            //                               // setState((){
            //                               //   isLoading3=false;
            //                               // })
            //                             });
            //                           },
            //                           // child: Text(parser.info('smiley').code)
            //                           child: Column(
            //                             children: [
            //                               SizedBox(
            //                                 width: temp == 3? 80*width/360: 50*width/360,
            //                                 height: temp ==3? 80*width/360: 50*width/360,
            //                                 child: Text(
            //                                   '🙂',
            //                                   style: TextStyle(
            //                                     fontSize: temp==3?70*width/360:40*width/360,
            //                                   ),
            //                                 ),
            //                               ),
            //                               SizedBox(
            //                                 width: 50*width/360,
            //                                 height: 50*width/360,
            //                                 child: Text(
            //                                   moods[2],
            //                                   textAlign: TextAlign.center,
            //                                     style: TextStyle(
            //                                         fontSize: temp==3?18*width/360:14*width/360
            //                                     )
            //                                 ),
            //                               )
            //                             ],
            //                           )
            //                       ),
            //                       TextButton(
            //                           onPressed: (){
            //                             // setState(() {
            //                             //   isLoading3 = true;
            //                             // });
            //                             setMood(2).then((resp)=>{
            //                               activity.addActivity(global.cid,'Mood Changed to ${moods[1]}').then((resp2)=>{
            //                                 print(moods[1])
            //                               }),
            //                               // setState((){
            //                               //   isLoading3=false;
            //                               // })
            //                             });
            //                           },
            //                           // child: Text(parser.info('smiley').code)
            //                           child: Column(
            //                             children: [
            //                               SizedBox(
            //                                 width: temp == 2? 80*width/360: 50*width/360,
            //                                 height: temp ==2? 80*width/360: 50*width/360,
            //                                 child: Text(
            //                                   '🙁',
            //                                   style: TextStyle(
            //                                     fontSize: temp==2?70*width/360:40*width/360,
            //                                   ),
            //                                 ),
            //                               ),
            //                               SizedBox(
            //                                 width: 50*width/360,
            //                                 height: 50*width/360,
            //                                 child: Text(
            //                                   moods[1],
            //                                   textAlign: TextAlign.center,
            //                                   style: TextStyle(
            //                                     fontSize: temp==2?20*width/360:14*width/360
            //                                   )
            //                                 ),
            //                               )
            //                             ],
            //                           )
            //                       ),
            //                       TextButton(
            //                           onPressed: (){
            //                             // setState(() {
            //                             //   isLoading3 = true;
            //                             // });
            //                             setMood(1).then((resp)=>{
            //                               activity.addActivity(global.cid,'Mood Changed to ${moods[0]}').then((resp2)=>{
            //                                 print(moods[0])
            //                               }),
            //                               // setState((){
            //                               //   isLoading3=false;
            //                               // })
            //                             });
            //                           },
            //                           // child: Text(parser.info('smiley').code)
            //                           child : Column(
            //                             children: [
            //                               SizedBox(
            //                                 width: temp == 1? 80*width/360: 50*width/360,
            //                                 height: temp ==1? 80*width/360: 50*width/360,
            //                                 child: Text(
            //                                   '😞',
            //                                   style: TextStyle(
            //                                     fontSize: temp==1?70*width/360:40*width/360,
            //                                   ),
            //                                 ),
            //                               ),
            //                               SizedBox(
            //                                 width: 50*width/360,
            //                                 height: 50*width/360,
            //                                 child: Text(
            //                                   moods[0],
            //                                   textAlign: TextAlign.center,
            //                                     style: TextStyle(
            //                                         fontSize: temp==1?18*width/360:14*width/360
            //                                     )
            //                                 ),
            //                               )
            //                             ],
            //                           )
            //                       ),
            //                     ]
            //                 );
            //               }
            //           );
            //         }
            //         else{
            //           return const SizedBox();
            //         }
            //       }
            //   ),
            // ),
          ]
      )
    );
  }
}


class MoodHolder extends StatefulWidget {
  // const MoodHolder({Key? key}) : super(key: key);
  GlobalKey<CircularMenuState> key = GlobalKey<CircularMenuState>();

  @override
  State<MoodHolder> createState() => _MoodHolderState();
}

class _MoodHolderState extends State<MoodHolder> {
  String _colorName = 'No';
  Color _color = Colors.black;
  @override
  Widget build(BuildContext context) {
    double pi = 3.14;
    return CircularMenu(
      alignment: Alignment.bottomCenter,
      backgroundWidget: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 28),
          ),
        ),
      ),
      toggleButtonColor: Colors.pink,
      items: [
        CircularMenuItem(
            // icon: Icons.home,
            icon: String2Icon.getIconDataFromString('mdiAccountArrowDown'),
            color: Colors.green,
            onTap: () {
              setState(() {
                _color = Colors.green;
                _colorName = 'Green';
              });
            }),
        CircularMenuItem(
            icon: Icons.search,
            color: Colors.blue,
            onTap: () {
              setState(() {
                _color = Colors.blue;
                _colorName = 'Blue';
              });
            }),
        CircularMenuItem(
            icon: Icons.settings,
            color: Colors.orange,
            onTap: () {
              setState(() {
                _color = Colors.orange;
                _colorName = 'Orange';
              });
            }),
        CircularMenuItem(
            icon: Icons.chat,
            color: Colors.purple,
            onTap: () {
              setState(() {
                _color = Colors.purple;
                _colorName = 'Purple';
              });
            }),
        CircularMenuItem(
            icon: Icons.notifications,
            color: Colors.brown,
            onTap: () {
              setState(() {
                _color = Colors.brown;
                _colorName = 'Brown';
              });
            })
      ],
    );
  }
}
