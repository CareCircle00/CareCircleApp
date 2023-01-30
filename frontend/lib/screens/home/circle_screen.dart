// import 'dart:typed_data';

import 'package:circular_motion/circular_motion.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/screens/home/chat_screen.dart';


bool isLoading = true;
bool isLoading2 = true;


List<Contact>contacts = [];

int getLovedOneImage(dynamic contact){
  int temp = -1;
  int i = 0;
  for (var element in contacts) {
    // print(element.phones!.elementAt(0).value.toString());
    if(element.phones!.length!=0 && element.phones!.elementAt(0).value.toString() == contact){
      temp = i;
    }
    ++i;
  }
  return temp;
}
int getPerson(dynamic contact) {
  int temp = -1;
  int i = 0;
  for (var element in contacts) {
    if (element.phones!.length != 0 && element.phones!.elementAt(0).value ==
        contact["mapValue"]["fields"]["memberNumber"]["stringValue"]) {
      temp = i;
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

class AddLovedOne extends StatelessWidget {
  const AddLovedOne({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, height*21/740, 0, 0),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    )
                )
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Circles',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(131,131,131,1),
                      fontSize: 18*width/360,
                    )
                  ),
                ),
                Align(
                  alignment: const Alignment(-0.8,0),
                  child:TextButton(
                    onPressed: (){

                      // HttpsCallable invite = FirebaseFunctions.instance.httpsCallable('user-addMemberToCircle');
                      // invite.call(<String,dynamic>{
                      //   // 'ph':-
                      // }).then((resp)=>{
                      //
                      // });
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16*width/360,
                        fontWeight: FontWeight.w500,
                      )
                    )
                  )
                ),
                Align(
                    alignment: const Alignment(0.8,0),
                    child:TextButton(
                        onPressed: (){
                          Navigator.pushNamed(context, '/contact_book_screen');
                        },
                        child: Text(
                            'Invite',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 16*width/360,
                              fontWeight: FontWeight.w500,
                            )
                        )
                    )
                ),
              ],
            ),
          ),
          Views(),

          // const Bottom(),
        ],
      );
  }
}

class Views extends StatefulWidget {
  const Views({Key? key}) : super(key: key);

  @override
  State<Views> createState() => _ViewsState();
}

class _ViewsState extends State<Views> {
  int view = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0.04*width, 0),
          child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: (){
                      if(view == 2){
                        setState(() {
                          view = 1;
                        });
                      }
                    },
                    // icon: Icon(Icons.circle_outlined)
                  icon: const Icon(Icons.blur_circular)
                ),
                IconButton(
                    onPressed: (){
                      if(view == 1){
                        setState(() {
                          view = 2;
                        });
                      }
                    },
                    icon: const Icon(Icons.list)
                )
              ]
          ),
        ),
        view == 1?Stack(
          children: <Widget>[
            SizedBox(
              height: height*0.7,
              child: SvgPicture.asset(
                'assets/svgs/add_loved_ones_bg.svg',
                fit: BoxFit.fill,
              ),
            ),
            const CenterImage(),
          ],
        ) :
        const CenterList(),
      ],
    );
  }
}

class CenterList extends StatefulWidget {
  const CenterList({Key? key}) : super(key: key);

  @override
  State<CenterList> createState() => _CenterListState();
}

class _CenterListState extends State<CenterList> {
  @override
  List<dynamic> mem = [];
  String loved_one = '';
  int l = -1;
  int? ind;
  void getAllContacts() async{
    List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    if(mounted){
      setState(() {
        contacts = getContacts;
        isLoading2 = false;
        // print(contacts[0].phones!.elementAt(0).value);
        // print(contacts[0].displayName![0]);
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCircle().then((val)=>{
      getAllContacts(),
      if(mounted){
        setState(() {
          mem = val["members"];
          loved_one = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
          isLoading = false;
        }),
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if(isLoading==false && isLoading2 == false){
      int i = getLovedOneImage(loved_one);
      if(mounted){
        setState(() {
          ind = i;
        });
      }
    }
    return SizedBox(
      // height: 578,
      height: height*0.7,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics : const NeverScrollableScrollPhysics(),
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0.01*height),
            child: Row(
              children: [
                ind != -1 && contacts[ind!].avatar!=null && contacts[ind!].avatar!.isNotEmpty?
                Container(
                  margin: EdgeInsets.fromLTRB(0.05*width,0, 0.025*width, 0),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(contacts[ind!].avatar!),
                    radius: 25,
                  ),
                ):
                ind!=-1 ? Container(
                  margin: EdgeInsets.fromLTRB(0.05*width,0, 0.025*width, 0),
                  child: CircleAvatar(
                    radius: 25,
                    child: Text(contacts[ind!].initials()),
                  ),
                ): const SizedBox(),
                ind!=-1? Text(
                  contacts[ind!].displayName!,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )
                :const SizedBox()
              ],
            ),
          ),
          Stack(
              alignment: Alignment.center,
              children: [
                isLoading==false && isLoading2 == false? ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: mem.length,
                    itemBuilder: (context, index) {
                      int ret = getPerson(mem[index]);
                      if(ret == -1){
                        return const SizedBox();
                      }
                      else if(contacts[ret].avatar!=null && contacts[ret].avatar!.isNotEmpty){
                        return Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0.01*height),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0.05*width,0, 0.025*width, 0),
                                child: CircleAvatar(
                                  backgroundImage: MemoryImage(contacts[ret].avatar!),
                                  radius: 25,
                                ),
                              ),
                              Text(
                                '${contacts[ret].displayName!}-(${mem[index]["mapValue"]["fields"]["status"]["stringValue"]})',
                                style: TextStyle(
                                  fontSize: 18*width/360,
                                ),
                              )
                            ],
                          ),
                        );
                      }else{
                        return Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0.01*height),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0.05*width,0, 0.025*width, 0),
                                child: CircleAvatar(
                                  radius: 25,
                                  child: Text(contacts[ret].initials()),
                                ),
                              ),
                              Text(
                                '${contacts[ret].displayName!}-(${mem[index]["mapValue"]["fields"]["status"]["stringValue"]})',
                                style: TextStyle(
                                  fontSize: 18*width/360,
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      // print(ret);
                    }
                ):const SizedBox()
              ]
          )
        ]
        ,
      ),
    );
  }
}


class CenterImage extends StatefulWidget {
  const CenterImage({Key? key}) : super(key: key);
  @override
  State<CenterImage> createState() => _CenterImageState();
}

class _CenterImageState extends State<CenterImage> {
  List<dynamic> mem = [];
  String loved_one = '';
  int l = -1;
  int? ind;
  void getAllContacts() async{
    List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    if(mounted){
      setState(() {
        contacts = getContacts;
        isLoading2 = false;
        // print(contacts[0].phones!.elementAt(0).value);
        // print(contacts[0].displayName![0]);
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCircle().then((val)=>{
      getAllContacts(),
      if(mounted){
        setState(() {
          mem = val["members"];
          loved_one = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
          isLoading = false;
        }),
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if(isLoading==false && isLoading2 == false){
      int i = getLovedOneImage(loved_one);
      if(mounted){
        setState(() {
          ind = i;
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
    return SizedBox(
      // height: 578,
      height: height*0.7,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          isLoading==false && isLoading2 == false? CircularMotion.builder(
              itemCount: mem.length,
              centerWidget:
              ind != -1 && contacts[ind!].avatar!=null && contacts[ind!].avatar!.isNotEmpty?
              CircleAvatar(
                backgroundImage: MemoryImage(contacts[ind!].avatar!),
                radius: 25,
              ):
              ind!=-1 ? CircleAvatar(
                radius: 25,
                child: Text(contacts[ind!].initials()),
              ): const SizedBox()
              ,
              builder: (context, index) {
                int ret = getPerson(mem[index]);
                if(ret == -1){
                  return const SizedBox();
                }
                else if(contacts[ret].avatar!=null && contacts[ret].avatar!.isNotEmpty){
                  return Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: MemoryImage(contacts[ret].avatar!),
                        radius: 25,
                      ),
                      Text(
                        mem[index]['mapValue']['fields']['status']['stringValue']
                      )
                    ],
                  );
                }else{
                  return SizedBox(
                    height: 100*height/740,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: Text(contacts[ret].initials()),
                        ),
                        Text(
                            mem[index]['mapValue']['fields']['status']['stringValue']
                        )
                      ],
                    ),
                  );
                }
                // print(ret);
              }
          ):const SizedBox()
        ]
      ),
    );
  }
}

class Bottom extends StatelessWidget {
  const Bottom({Key? key}) : super(key: key);

  @override

  @override
  Widget build(BuildContext context) {

    return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        alignment: Alignment.center,
        child: ElevatedButton(
            onPressed: (){
              // Navigator.pushNamed(context, '/select_action_screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: const BorderSide(
                color: Colors.blueAccent,
                width: 1.5,
              ),
              elevation: 0,
            ),
            child: const Text(
                'Find nearest caregivers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                )
            )
        )
    );
  }
}
