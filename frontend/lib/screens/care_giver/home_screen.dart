import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../global.dart' as global;


bool isLoading = true;
bool isLoading2 = true;





// List<Contact>contacts = [];
List all_contacts = [];


Future<int> getMood(String cid)async{
  int i = 0;
  HttpsCallable gM = FirebaseFunctions.instance.httpsCallable('circle-getCurrentMood');
  await gM.call(<String,dynamic>{
    'cid':cid
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
  HttpsCallable getCircle = FirebaseFunctions.instance.httpsCallable('circle-getCircleMembers');
  await getCircle.call(<String,dynamic>{
    'phno': phno,
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
          // print(val['lovedOne']['mapValue']['fields']['invitationStatus']['stringValue']);
          loved_one_status = val['lovedOne']['mapValue']['fields']['invitationStatus']['stringValue'];
          loved_one = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
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
      // if(ret == -1){
      //   const SizedBox();
      // }
      // else if(contacts[ret].avatar!=null && contacts[ret].avatar!.isNotEmpty){
      //   CircleAvatar(
      //     backgroundImage: MemoryImage(contacts[ret].avatar!),
      //     radius: 25,
      //   );
      // }else{
      //   CircleAvatar(
      //     radius: 25,
      //     child: Text(contacts[ret].initials()),
      //   );
      // }
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    print(loved_one_status);
    return ListView(
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
                        width: 56,
                        height: 56,
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

                    ): SizedBox()

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
                          isLoading == false && isLoading2 == false && ind!=-1? all_contacts[ind!].displayName: '',
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
                          'Last online',
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
                      // ElevatedButton(
                      //     onPressed: (){
                      //       print('Some more');
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //         backgroundColor: const Color.fromRGBO(25,45,227,0.7 ),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(100),
                      //         )
                      //     ),
                      //     child: const Text(
                      //       'Ask if something is needed',
                      //       // style:
                      //     )
                      // ),
                    ]
                ),
              )
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 0.5,
                        color: Colors.grey
                    )
                )
            ),
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
        Container(
          margin: EdgeInsets.fromLTRB(0,   10*height/740, 0, 0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Activity').doc(global.cid).collection('List').snapshots(),
            builder: (context,snapshot){

              if(snapshot.connectionState == ConnectionState.waiting){
                return const SizedBox();
              }
              else if(snapshot.connectionState == ConnectionState.active){
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.size,
                    itemBuilder:(BuildContext context, int index){
                      // print(DateTime.now());
                      // print(snapshot.data!.docs.elementAt(index)['timestamp']);
                      var pos = snapshot.data!.docs.elementAt(index)["timestamp"].lastIndexOf('.');
                      String result = (pos != -1)? snapshot.data!.docs.elementAt(index)["timestamp"].substring(0, pos): snapshot.data!.docs.elementAt(index)["timestamp"];
                      return Container(
                        padding: EdgeInsets.fromLTRB(0, 5*height/740, 0, 5*height/740),
                        margin: EdgeInsets.fromLTRB(30*width/360, 0, 30*width/360, 0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                            )
                          )
                        ),
                        child: Text(
                          '${snapshot.data!.docs.elementAt(index)["activity"]} - $result',
                          style: TextStyle(
                            fontSize: 16*width/360,
                          ),
                        )
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