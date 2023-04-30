import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import '../../global.dart' as global;

bool? circleSelected;
int pg=0;
bool isLoading = true;
bool isLoading2 = true;


List<Contact>contacts = [];
List all_contacts = [];
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
      if(element.phones[0] == contact["mapValue"]["fields"]["memberNumber"]["stringValue"]) {
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

Future<bool?> checkCircleUID() async{
  bool rval=false;
  HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
  await getCircleUID.call().then((response)=>{
    // print(response.data["cid"]),
    if(response.data["cid"] != null) rval=true else rval=false,
  }).catchError((err)=>{
    print(err),
  });
  return rval;
}
Future<int> checkCircleUID2() async{
  int rval =0;
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  String phno = user!.phoneNumber!;
  HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
  await getCircleUID.call(<String,dynamic>{
    'phno' : phno,
  }).then((response)=>{
    if(response.data["cid"] != null) rval=2 else rval=1,
  }).catchError((err)=>{
    print(err),
  });
  return rval;
}

class AddLovedOneScreen extends StatelessWidget {
  const AddLovedOneScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: AddLovedOne(),
        body: Setup(),
        appBar: AppBar(
            title: Text('Care Circle')
        ),
      );
  }
}

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  List list =[];
  @override
  Widget build(BuildContext context) {
    setState(() {
      list = global.list;
    });
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
        // shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20*width/360, 10*height/740, 20*width/360, 0*height/740),
            child: Text(
              "Let's setup your loved one's experience",
              style: TextStyle(
                fontSize: 18*width/360,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20*width/360, 10*height/740, 20*width/360, 10*height/740),
            child: Text(
              'This is what they see when they log in',
              style: TextStyle(
                fontSize: 18*width/360
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
            // padding: EdgeInsets.fromLTRB(20*width/460, 0, 20*width/460, 0),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: list.length<2?1:2,
                mainAxisExtent: 120*height/740,
                mainAxisSpacing: 5,
              ),
              itemCount: list.length,
              itemBuilder: (BuildContext context, index){

                return Container(
                  child: ElevatedButton(
                      onPressed: () {
                        // handlePressed(actsList[index]);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                      child: Text(
                        list[index]["name"],
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: (){
                Navigator.pushNamed(context, '/select_action_screen');
              },
              child:Text(
                'Want to customize?',
                style: TextStyle(
                  fontSize: 15*width/360
                )
              )
            )
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.fromLTRB(0,10*height/740,10*width/360,0),
              child: ElevatedButton(
                child: Text(
                  'Proceed to invite your Loved One',
                  style: TextStyle(
                    fontSize: 15*width/360
                  )
                ),
                onPressed: ()async{
                  if (await Permission.contacts.request().isGranted) {
                    Navigator.pushNamed(context, '/contact_book_screen');
                    // Either the permission was already granted before or the user just granted it.
                  }
                },
              ),
            ),
          )
        ]
    );
  }
}




//
//
// class AddLovedOne extends StatelessWidget {
//   const AddLovedOne({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     return ListView(
//       physics: const NeverScrollableScrollPhysics(),
//       children: <Widget>[
//         Container(
//           // width:243,
//           width: width,
//           height:34*height/740,
//           margin: EdgeInsets.fromLTRB(0, 73*height/740, 0, 35*height/740),
//           alignment: Alignment.center,
//           child:Text(
//             'Add your loved one',
//             style: TextStyle(
//               fontSize: 28*height/740,
//               fontWeight: FontWeight.w500,
//             ),
//           )
//         ),
//         Stack(
//           children: <Widget>[
//             SizedBox(
//               // height: 578,
//               height: (480)*height/740,
//               child: SvgPicture.asset(
//                 'assets/svgs/add_loved_ones_bg.svg',
//                 fit: BoxFit.fill,
//               ),
//             ),
//             const CenterImage(),
//           ],
//         ),
//         const Bottom(),
//       ],
//     );
//   }
// }
//
// class CenterImage extends StatefulWidget {
//   const CenterImage({Key? key}) : super(key: key);
//
//   @override
//   State<CenterImage> createState() => _CenterImageState();
// }
//
// class _CenterImageState extends State<CenterImage> {
//
//   void getAllContacts() async{
//     // List<Contact> getContacts = (await ContactsService.getContacts()).toList();
//     // List get_all_contacts = await FastContacts.allContacts;
//     if(mounted){
//       setState(() {
//         // all_contacts = get_all_contacts;
//         isLoading2 = false;
//         // print(contacts[0].phones!.elementAt(0).value);
//         // print(contacts[0].displayName![0]);
//       });
//     }
//   }
//
//   String loved_one = '';
//   int? ind;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     checkCircleUID2().then((val)=>{
//       if(val == 2) {
//         if(mounted){
//           setState((){
//             circleSelected = true;
//             getCircle().then((val)=>{
//               getAllContacts(),
//               setState(() {
//                 loved_one = val['lovedOne']["mapValue"]["fields"]["lovedOnephNo"]["stringValue"];
//                 isLoading = false;
//               }),
//             });
//           })
//         }
//       }
//       else if(val==1){
//         if(mounted){
//           setState((){
//             circleSelected = false;
//           })
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     late Future<Uint8List?> _imageFutureLovedOne;
//     int i = getLovedOneImage(loved_one);
//     if(mounted){
//       setState(() {
//         ind = i;
//         if(i!=-1){
//           _imageFutureLovedOne = FastContacts.getContactImage(all_contacts[ind!].id);
//         }
//       });
//     }
//     // print(ind);
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return SizedBox(
//       height: (480)*height/700,
//       child: Center(
//         child:
//         isLoading == false && isLoading2==false && circleSelected==true?
//         (
//         //  CircleAvatar(
//         //     radius: 25,
//         //     child: Text('C'),
//         //   )
//             ind!=null&&ind!=-1?FutureBuilder<Uint8List?>(
//               future: _imageFutureLovedOne,
//               builder: (context, snapshot) => Container(
//                 width: 56,
//                 height: 56,
//                 child: snapshot.hasData?
//                 CircleAvatar(
//                   backgroundImage: MemoryImage(snapshot.data!),
//                   radius:25,
//                 )
//                 // ? Image.memory(snapshot.data!, gaplessPlayback: true)
//                     :
//                 CircleAvatar(
//                   radius: 25,
//                   child: Text(
//                       all_contacts[ind!].displayName[0],
//                       style: TextStyle(
//                           fontSize: 18*width/360
//                       )
//                   ),
//                 ),
//               ),
//
//             ): SizedBox()
//         //     ind != -1 && contacts[ind!].avatar!=null && contacts[ind!].avatar!.isNotEmpty?
//         //     CircleAvatar(
//         //       backgroundImage: MemoryImage(contacts[ind!].avatar!),
//         //       radius: 25,
//         //     ):
//         //     CircleAvatar(
//         //       radius: 25,
//         //       child: Text(contacts[ind!].initials()),
//         //     )
//
//         )
//         :IconButton(
//           icon: SvgPicture.asset(
//             'assets/svgs/plus_button.svg',
//           ),
//           style: IconButton.styleFrom(
//
//           ),
//           onPressed: () async {
//             // print('pressed');
//             // final auth = FirebaseAuth.instance;
//             //         await auth.signOut();
//             if (await Permission.contacts.request().isGranted) {
//
//               Navigator.pushNamed(context, '/contact_book_screen');
//               // Either the permission was already granted before or the user just granted it.
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
// class Bottom extends StatefulWidget {
//   const Bottom({Key? key}) : super(key: key);
//
//   @override
//   State<Bottom> createState() => _BottomState();
// }
//
// class _BottomState extends State<Bottom> {
//   @override
//
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // checkCircleUID().then((val)=>{
//     //   if(val == true) {
//     //     setState((){
//     //       circleSelected = true;
//     //     })
//     //   }
//     //   else{
//     //     setState((){
//     //       circleSelected = false;
//     //     })
//     //   }
//     // });
//     checkCircleUID2().then((val)=>{
//       if(val == 2) {
//         if(mounted){
//           setState((){
//             circleSelected = true;
//           })
//         }
//       }
//       else if(val==1){
//         if(mounted){
//           setState((){
//             circleSelected = false;
//           })
//         }
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//
//     return circleSelected==true?
//         Container(
//           margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//           alignment: Alignment.center,
//           child: ElevatedButton(
//             onPressed: (){
//               Navigator.pushNamed(context, '/select_action_screen');
//             },
//             child: const Text(
//               'Continue',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               )
//             )
//           )
//         ): const SizedBox();
//     //     :Container(
//     //     alignment: Alignment.center,
//     //     child: TextButton(
//     //       onPressed: () async {
//     //
//     //         //signout
//     //         final auth = FirebaseAuth.instance;
//     //         await auth.signOut();
//     //
//     //         // delete user
//     //         // final user = FirebaseAuth.instance.currentUser;
//     //         // user!.delete();
//     //       },
//     //       child: const Text(
//     //         "I'll do this later",
//     //         style: TextStyle(
//     //           color: Color.fromRGBO(71, 87, 233, 1),
//     //           fontSize: 18,
//     //           fontWeight: FontWeight.w600,
//     //         ),
//     //       ),
//     //     )
//     // );
//   }
// }
