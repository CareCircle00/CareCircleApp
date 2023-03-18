// import 'dart:typed_data';

import 'dart:typed_data';

import 'package:circular_motion/circular_motion.dart';
import 'package:cloud_functions/cloud_functions.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/screens/care_giver/chat_screen.dart';
import 'package:fast_contacts/fast_contacts.dart';

import '../../global.dart' as global;

bool isLoading = true;
bool isLoading2 = true;


// List<Contact>contacts = [];
List<dynamic>all_contacts = [];

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
      if(element.phones[0] == contact["memberNumber"]) {
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
          // Container(
          //   margin: EdgeInsets.fromLTRB(0, height*5/740, 0, 0),
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       Align(
          //         alignment: Alignment.center,
          //         child: Text(
          //           'My Circle',
          //           style: TextStyle(
          //             fontWeight: FontWeight.w600,
          //             color: const Color.fromRGBO(131,131,131,1),
          //             fontSize: 18*width/360,
          //           )
          //         ),
          //       ),
          //       Align(
          //           alignment: const Alignment(0.8,0),
          //           child:TextButton(
          //               onPressed: (){
          //                 Navigator.pushNamed(context, '/contact_book_screen');
          //               },
          //               child: Text(
          //                   'Invite',
          //                   style: TextStyle(
          //                     color: Colors.blueAccent,
          //                     fontSize: 16*width/360,
          //                     fontWeight: FontWeight.w500,
          //                   )
          //               )
          //           )
          //       ),
          //     ],
          //   ),
          // ),




          //to get back multiple views uncomment this
          // Views(),

          Container(
            margin: EdgeInsets.fromLTRB(0, 20*height/740, 0, 20*height/740),
            child: CenterList(),
          )

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
          margin: EdgeInsets.fromLTRB(0, 20*height/740, 0.04*width, 0),
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
  static dynamic per;
  static dynamic mem;
  @override
  State<CenterList> createState() => _CenterListState();
}

class _CenterListState extends State<CenterList> {

  List<dynamic> mem = [];
  String loved_one_num = '';
  dynamic loved_one;
  @override
  int l = -1;
  int? ind;
  void getAllContacts() async{
    // List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    List get_all_contacts = await FastContacts.allContacts;
    if(mounted){
      setState(() {
        // contacts = getContacts;
        all_contacts = get_all_contacts;
        isLoading2 = false;
        // print(contacts[0].phones!.elementAt(0).value);
        // print(contacts[0].displayName![0]);
      });
    }
  }
  final phno = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCircleFromCID().then((resp)=>{
      getAllContacts(),
      if(mounted){
        setState(() {
          mem = resp["circle"]["members"];
          loved_one = resp["circle"]["lovedOne"];
          loved_one_num = resp["circle"]["lovedOne"]["lovedOnephNo"];
          isLoading = false;
        }),
      }
              // getCircle().then((val)=>{
              // getAllContacts(),
              // if(mounted){
              // setState(() {
              // print(val);
              // // mem = val["members"];
              // lovedOne = val['lovedOne']["mapValue"]["fields"];
              // loved_one_num = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
              // isLoading = false;
              // }),
              // }
              // }),
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isLoading3 = true;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    late Future<Uint8List?> _imageFutureLovedOne;
    if(isLoading==false && isLoading2 == false){
      int i = getLovedOneImage(loved_one_num);
      if(mounted){
        setState(() {
          ind = i;
          isLoading3=false;
          if(i!=-1){
            _imageFutureLovedOne = FastContacts.getContactImage(all_contacts[ind!].id);
          }
        });
      }
    }
    return SizedBox(
      // height: 578,
      height: height*0.9,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        // shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0.03*width, 0, 0.03*width, 0.01*height),
            padding: EdgeInsets.fromLTRB(0.05*width,0,0,0.01*height),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Column(
              children: [
                ind!=null&&ind!=-1?FutureBuilder<Uint8List?>(
                  future: _imageFutureLovedOne,
                  builder: (context, snapshot) => Container(
                    width: 100*width/360,
                    height: 100*width/360,
                    child: snapshot.hasData?
                    CircleAvatar(
                      backgroundImage: MemoryImage(snapshot.data!),
                      radius:50*width/360,
                    )
                    // ? Image.memory(snapshot.data!, gaplessPlayback: true)
                        :
                    CircleAvatar(
                      radius: 50*width/360,
                      child: Text(
                        all_contacts[ind!].displayName[0],
                        style: TextStyle(
                            fontSize: 24*width/360
                        )
                      ),
                    ),
                  ),

                ):  CircleAvatar(
                    radius: 50*width/360,
                    backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
                ),
                ind!=null?Container(
                  margin: EdgeInsets.fromLTRB(0, 10*height/740, 0, 10*height/740),
                  child:
                    ind==-1?
                    Text(
                        loved_one_num,
                      style: TextStyle(
                        fontSize: 20*width/360
                      )
                    ):
                    Text(
                      all_contacts[ind!].displayName,
                        style: TextStyle(
                            fontSize: 20*width/360
                        )
                    ),
                ):const SizedBox()
              ]
            )
          ),
          Stack(
              alignment: Alignment.center,
              children: [
                isLoading==false && isLoading2 == false? ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    // physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: mem.length,
                    itemBuilder: (context, index) {
                      // int ret = getPerson(mem[index]);
                      late Future<Uint8List?> _imageFuture;
                      int ret = getPerson(mem[index]);
                      if(ret!=-1){
                        _imageFuture = FastContacts.getContactImage(all_contacts[ret].id);
                        // FastContacts.getContactImage(all_contacts[ret].id).then((resp)=>{
                        //   print('here:$resp'),
                        // });
                      }
                      return Container(
                        margin: EdgeInsets.fromLTRB(0.03*width, 0, 0.03*width, 0.01*height),
                        padding: EdgeInsets.fromLTRB(0,0,0,0.01*height),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0.05*width,0, 0.025*width, 0),
                                child: Row(
                                  children: [
                                    ret!=-1?
                                    FutureBuilder<Uint8List?>(
                                      future: _imageFuture,
                                      builder: (context, snapshot) => Container(
                                        width: 50*width/360,
                                        height: 50*width/360,
                                        child: snapshot.hasData
                                            ?
                                        CircleAvatar(
                                          backgroundImage: MemoryImage(snapshot.data!),
                                          radius:25*width/360,
                                        )
                                        // Image.memory(snapshot.data!, gaplessPlayback: true)
                                            :
                                        CircleAvatar(
                                          radius: 25*width/360,
                                          child: Text(all_contacts[ret].displayName[0]),
                                        ),
                                      ),
                                    ):
                                    CircleAvatar(
                                      radius: 25*width/360,
                                      backgroundImage: AssetImage('assets/images/profile.png') as ImageProvider,
                                      // child: Text(
                                      //   phno == mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"]?'You':mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"][0],
                                      //   style: TextStyle(
                                      //     fontSize: 18*width/360
                                      //   )
                                      // ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(10*width/360, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children : [
                                          ret==-1?
                                          Text(
                                            phno == mem[index]["memberNumber"]? 'Myself' : mem[index]["memberNumber"]
                                            // phno == mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"]? 'Myself':mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"],
                                          ):
                                          Text(
                                            all_contacts[ret].displayName,
                                          ),
                                          mem[index]['status'] == 'Accepted'? const SizedBox():
                                          // mem[index]['mapValue']['fields']['status']['stringValue'] == 'Accepted'?const SizedBox():
                                          Text(
                                            mem[index]['status'],
                                              // mem[index]['mapValue']['fields']['status']['stringValue'],
                                              style: TextStyle(
                                                fontSize: 10*width/360,
                                              )
                                          ),
                                        ]
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 10*width/360, 0),
                                  child: TextButton(
                                    onPressed: (){
                                      CenterList.per = ret;
                                      CenterList.mem = mem[index];
                                      Navigator.pushNamed(context, '/invitation_screen');
                                    },
                                    child: Text(
                                      '>',
                                      style: TextStyle(
                                        fontSize: 18*width/360
                                      )
                                    ),
                                  )
                                ),
                              )
                            ],
                          )
                        )
                      );
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
    List get_all_contacts = await FastContacts.allContacts;
    if(mounted){
      setState(() {
        all_contacts = get_all_contacts;
        isLoading2 = false;
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
    late Future<Uint8List?> _imageFutureLovedOne;
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
    return SizedBox(
      height: height*0.7,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          isLoading==false && isLoading2 == false? CircularMotion.builder(
              itemCount: mem.length,
              centerWidget:
              SizedBox(
                height: 100,
                child: Column(
                  children: [
                    ind!=null&&ind!=-1?FutureBuilder<Uint8List?>(
                      future: _imageFutureLovedOne,
                      builder: (context, snapshot) => Container(
                        width: 56,
                        height: 56,
                        child: snapshot.hasData?
                        CircleAvatar(
                          backgroundImage: MemoryImage(snapshot.data!),
                          radius:25,
                        )
                            // ? Image.memory(snapshot.data!, gaplessPlayback: true)
                            :
                        CircleAvatar(
                          child: Text(all_contacts[ind!].displayName[0]),
                          radius: 25,
                        ),
                      ),

                    ): SizedBox(),
                    // CircleAvatar(
                    //   child: Text(mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"][0]),
                    //   radius: 25,
                    // ),
                    ind==-1?
                    Text(
                      'Loved One'
                    ):
                    Text(
                      all_contacts[ind!].displayName,
                    ),
                  ]
                )
              ),
              builder: (context, index) {
                late Future<Uint8List?> _imageFuture;
                int ret = getPerson(mem[index]);
                if(ret!=-1){
                _imageFuture = FastContacts.getContactImage(all_contacts[ret].id);
                }
                return SizedBox(
                    height: 100*height/740,
                    child: Column(
                      children: [
                        ret!=-1?FutureBuilder<Uint8List?>(
                          future: _imageFuture,
                          builder: (context, snapshot) => Container(
                            width: 56,
                            height: 56,
                            child: snapshot.hasData
                                ?
                            CircleAvatar(
                              backgroundImage: MemoryImage(snapshot.data!),
                              radius:25,
                            )
                            // Image.memory(snapshot.data!, gaplessPlayback: true)
                                :
                            CircleAvatar(
                              child: Text(all_contacts[ret].displayName[0]),
                              radius: 25,
                            ),
                          ),
                        ):
                        CircleAvatar(
                          child: Text(mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"][0]),
                          radius: 25,
                        ),
                        ret==-1?
                        Text(
                          mem[index]["mapValue"]["fields"]["memberNumber"]["stringValue"],
                        ):
                        Text(
                          all_contacts[ret].displayName,
                        ),
                        mem[index]['mapValue']['fields']['status']['stringValue'] == 'Accepted'?const SizedBox():
                        Text(
                            mem[index]['mapValue']['fields']['status']['stringValue'],
                            style: const TextStyle(
                              fontSize: 10,
                            )
                        )
                      ],
                    ),
                  );
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
