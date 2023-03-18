import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../global.dart' as global;
import 'package:timeago/timeago.dart' as timeago;

bool isLoading = true;
bool isLoading2 = true;


// List<Contact>contacts = [];
List all_contacts = [];

Future<String> getPhno()async{
  String phno = '';
  HttpsCallable checkUser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
  await checkUser.call().then((resp){
    phno = resp.data['user']['ph'];
  });
  return phno;
}

Future<int> getPerson(String contact)async {
  int temp = -1;
  int i = 0;
  for (var element in all_contacts) {
    // if (element.phones!.isNotEmpty && element.phones!.elementAt(0).value ==
    //     contact["mapValue"]["fields"]["memberNumber"]["stringValue"]) {
    //   temp = i;
    // }
    if(!element.phones.isEmpty){
      // if(element.phones[0] == resp.data['user']['ph']){
      if(element.phones[0] == contact){
        temp = i;
        break;
      }
    }
    ++i;
  }
  return temp;
}



Future<int> getMood()async{
  int i = 0;
  HttpsCallable gM = FirebaseFunctions.instance.httpsCallable('circle-getCurrentMood');
  await gM.call(<String,dynamic>{
    'cid':global.cid
  }).then((resp)=>{
    if(resp.data['mood']!=null){
      i = resp.data["mood"],
    }
  });
  return i;
}

int getLovedOneImage(dynamic contact){
  int temp = -1;
  int i = 0;
  for (var element in all_contacts) {
    // print(element.phones!.elementAt(0).value.toString());
    // if(element.phones!.length!=0 && element.phones!.elementAt(0).value.toString() == contact){
    //   temp = i;
    // }
    if(element.phones!.isNotEmpty){
      if(element.phones[0]==contact){
        temp = i;
        break;
      }
    }
    ++i;
  }
  return temp;
}

Future<dynamic> getCircle() async{
  dynamic rval = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  String phno = user!.phoneNumber!;
  HttpsCallable getCircle = FirebaseFunctions.instance.httpsCallable('circle-getCircle');
  await getCircle.call(<String,dynamic>{
    'circleID':global.cid
  }).then((response)=>{
    rval = response.data,
  });
  return rval;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  String loved_one = '';
  String loved_one_status = '';
  String lonline = '';
  DateTime? dt;
  int l = -1;
  int? ind;

  void getAllContacts() async{
    // List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    List get_contacts = await FastContacts.allContacts;
    if(mounted){
      setState(() {
        // contacts = getContacts;
        all_contacts = get_contacts;
        isLoading2 = false;
        // print(contacts[0].phones!.elementAt(0).value);
        // print(contacts[0].displayName![0]);
      });
    }
  }



  late Future<Uint8List?> _imageFutureLovedOne;
  void initState() {
    // TODO: implement initState
    super.initState();

    getCircle().then((val)=>{
      getAllContacts(),
      if(mounted){
        // print('val:$val'),
        setState(() {
          print(val);
          // lonline = val['lastOnline']['stringValue'];
          lonline = val['circle']['lastOnline'];
          dt = DateTime.parse(lonline);
          // String luid = val['lovedOne']['mapValue']['fields']['lovedOneuid']['stringValue'];
          loved_one_status = val['circle']['lovedOne']['invitationStatus'];
          // loved_one_status = val['lovedOne']['mapValue']['fields']['invitationStatus']['stringValue'];
          // loved_one = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
          loved_one = val['circle']['lovedOne']['lovedOnephNo'];
          isLoading = false;
        }),
      }
    });
  }
  Widget build(BuildContext context) {
    if(isLoading==false && isLoading2 == false){
      int i = getLovedOneImage(loved_one);
      if(mounted){
        setState(() {
          ind = i;
          if(i!=-1){
            _imageFutureLovedOne = FastContacts.getContactImage(all_contacts[ind!].id);
          }
        });
      }
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          width: 80,
          height: 80,

          child: Stack(
            alignment: Alignment.center,
            children:<Widget>[
              Align(
                alignment: const Alignment(-0.85,0),
                child: isLoading == false && isLoading2==false?
                (
                    ind!=null&&ind!=-1?FutureBuilder<Uint8List?>(
                      future: _imageFutureLovedOne,
                      builder: (context, snapshot) => Container(
                        width: 70,
                        height: 70,
                        child: snapshot.hasData?
                        CircleAvatar(
                          backgroundImage: MemoryImage(snapshot.data!),
                          radius: 35*width/360,
                        )
                        // ? Image.memory(snapshot.data!, gaplessPlayback: true)
                            :
                        CircleAvatar(
                          radius: 35*width/360,
                          child: Text(all_contacts[ind!].displayName[0]),
                        ),
                      ),

                    ): CircleAvatar(
                      radius: 35*width/360,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                      // child: loved_one.isNotEmpty?Text(loved_one[0]):const Text(''),
                    )

                )    : const SizedBox()
              ),
              Align(
                alignment: const Alignment(0.25,0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width*180/360,
                        child: Text(
                          isLoading == false && isLoading2 == false && ind!=-1? all_contacts[ind!].displayName: loved_one,
                          // isLoading == false && isLoading2==false&&ind!=-1? contacts[ind!].displayName!:'',
                          style: TextStyle(
                            fontSize: 22*width/360,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w600,
                          )
                        )
                      ),
                      loved_one_status == 'Accepted' ?SizedBox(
                        width: width*180/360,
                        child: Text(
                          dt!=null?'Last online ${timeago.format(dt!)}':'Last online',
                          style: TextStyle(
                            fontSize: 16*width/360,
                            fontWeight: FontWeight.w500,
                            // color: const Color.fromRGBO(0, 0, 0, 0.5),
                            color: Colors.grey
                          ),
                        ),
                      ): const SizedBox(),
                      loved_one_status == 'Pending' ?SizedBox(
                        width: width*180/360,
                        child: Text(
                          'Invitation Pending',
                          style: TextStyle(
                            fontSize: 16*width/360,
                            fontWeight: FontWeight.w500,
                            // color: const Color.fromRGBO(0, 0, 0, 0.5),
                            color: Colors.grey
                          ),
                        ),
                      ): const SizedBox(),
                    ]
                ),
              )
            ],
          ),
        ),
        Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 0.5,
                        color: Colors.grey
                    )
                )
            ),
            margin: EdgeInsets.fromLTRB(0,   0*height/740, 0, 0),
            padding: EdgeInsets.fromLTRB(0,15*height/740,0,0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Circle').doc(global.cid).collection('mood').orderBy('timestamp',descending: true).snapshots(),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const SizedBox();
                }
                else if(snapshot.connectionState == ConnectionState.active){
                  print(snapshot.data!.size);
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.size==0? 0:1,
                      itemBuilder:(BuildContext context, int index){
                        // print('here:${snapshot.data!.docs.elementAt(index)['mood']}');
                        int temp = snapshot.data!.docs.elementAt(index)['mood'];
                        if(temp == 5){
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(25*width/360,0,0,0),
                                child: Text(
                                    'Current Mood:',
                                    style: TextStyle(
                                      fontSize: 18*width/360,
                                    )
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20*width/360, 0, 0, 0),
                                  child: Text(
                                    '😀',
                                    style: TextStyle(
                                      fontSize: 40*width/360,
                                    ),
                                  )
                              ),
                            ],
                          );
                        }else if(temp == 4){
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(25*width/360,0,0,0),
                                child: Text(
                                    'Current Mood:',
                                    style: TextStyle(
                                      fontSize: 18*width/360,
                                    )
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20*width/360, 0, 0, 0),
                                  child: Text(
                                    '☺',
                                    style: TextStyle(
                                      fontSize: 40*width/360,
                                    ),
                                  )
                              ),
                            ],
                          );
                        }else if(temp == 3){
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(25*width/360,0,0,0),
                                child: Text(
                                    'Current Mood:',
                                    style: TextStyle(
                                      fontSize: 18*width/360,
                                    )
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20*width/360, 0, 0, 0),
                                  child: Text(
                                    '🙂',
                                    style: TextStyle(
                                      fontSize: 40*width/360,
                                    ),
                                  )
                              ),
                            ],
                          );
                        }else if(temp == 2){
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(25*width/360,0,0,0),
                                child: Text(
                                    'Current Mood:',
                                    style: TextStyle(
                                      fontSize: 18*width/360,
                                    )
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20*width/360, 0, 0, 0),
                                  child: Text(
                                    '🙁',
                                    style: TextStyle(
                                      fontSize: 40*width/360,
                                    ),
                                  )
                              ),
                            ],
                          );
                        }else if(temp == 1){
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(25*width/360,0,0,0),
                                child: Text(
                                    'Current Mood:',
                                    style: TextStyle(
                                      fontSize: 18*width/360,
                                    )
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20*width/360, 0, 0, 0),
                                  child: Text(
                                    '😞',
                                    style: TextStyle(
                                      fontSize: 40*width/360,
                                    ),
                                  )
                              ),
                            ],
                          );
                        }else{
                          return SizedBox();
                        }
                      }
                  );
                }
                else{
                  return const SizedBox();
                }
              }
          ),
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            // decoration: const BoxDecoration(
            //     border: Border(
            //         top: BorderSide(
            //             width: 0.5,
            //             color: Colors.grey
            //         )
            //     )
            // ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20,20,0,0),
                    child: Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 22*width/360,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Align(
                //     alignment: Alignment.centerRight,
                //     child: Container(
                //         margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                //         child: Text(
                //           'Thursday, 3 Nov',
                //           style: TextStyle(
                //             fontWeight: FontWeight.w600,
                //             fontSize: 14*width/360,
                //             color: Colors.grey,
                //           ),
                //         )
                //     )
                // )
              ],
            )
        ),
        // Container(
        //   child:
        // ),
        Container(
          margin: EdgeInsets.fromLTRB(0,   10*height/740, 0, 0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Activity').doc(global.cid).collection('List').orderBy('timestamp',descending: true).snapshots(),
            builder: (context,snapshot){

              if(snapshot.connectionState == ConnectionState.waiting){
                return const SizedBox();
              }
              else if(snapshot.connectionState == ConnectionState.active){
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.size,
                    itemBuilder:(BuildContext context, int index){
                      var pos = snapshot.data!.docs.elementAt(index)["timestamp"].lastIndexOf('.');
                      late Future<Uint8List?> _imageFuture;
                      int ret = -1;
                      if(ret!=-1){
                        _imageFuture = FastContacts.getContactImage(all_contacts[ret].id);
                        // FastContacts.getContactImage(all_contacts[ret].id).then((resp)=>{
                        //   print('here:$resp'),
                        // });
                      }
                      String result = (pos != -1)? snapshot.data!.docs.elementAt(index)["timestamp"].substring(0, pos): snapshot.data!.docs.elementAt(index)["timestamp"];
                      print(snapshot.data!.docs.elementAt(index)['uid']);
                      HttpsCallable getUser = FirebaseFunctions.instance.httpsCallable('user-getUser');
                      // getUser.call(<String,dynamic>{
                      //   'uid':snapshot.data!.docs.elementAt(index)['uid'],
                      // }).then((resp)=>{
                      //   print(resp)
                      // });
                      return Container(
                        padding: EdgeInsets.fromLTRB(0, 10*height/740, 0, 10*height/740),
                        margin: EdgeInsets.fromLTRB(30*width/360, 0, 40*width/360, 0),
                        decoration: const BoxDecoration(

                            border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                )
                            )
                        ),
                        child: ListTile(
                            leading :ret!=null&&ret!=-1?FutureBuilder<Uint8List?>(
                              future: _imageFuture,
                              builder: (context, snapshot) => Container(
                                width: 30*width/360,
                                height: 30*width/360,
                                child: snapshot.hasData?
                                CircleAvatar(
                                  backgroundImage: MemoryImage(snapshot.data!),
                                  radius:30*width/360,
                                )
                                // ? Image.memory(snapshot.data!, gaplessPlayback: true)
                                    :
                                CircleAvatar(
                                  radius: 30*width/360,
                                  child: Text(
                                      all_contacts[ret!].displayName[0],
                                      style: TextStyle(
                                          fontSize: 24*width/360
                                      )
                                  ),
                                ),
                              ),

                            ):  CircleAvatar(
                              radius: 30*width/360,
                              backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
                              // child: Text(
                              //     loved_one_num.isNotEmpty? loved_one_num[0]: '',
                              //     style: TextStyle(
                              //         fontSize: 25*width/360
                              //     )
                              // ),
                            ),
                            title: Text(
                              '${snapshot.data!.docs.elementAt(index)["activity"]} - ${timeago.format(DateTime.parse(result))}',
                              style: TextStyle(
                                fontSize: 18*width/360,
                              ),
                            )
                        ),
                      );
                    }
                );
              }
              else{
                return const SizedBox();
              }
            }
          )
        )
      ],
    );
  }
}