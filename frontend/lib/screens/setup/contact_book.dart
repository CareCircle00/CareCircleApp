import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:frontend/helper/activity.dart';
import 'package:frontend/screens/setup/add_loved_one.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fast_contacts/fast_contacts.dart';

import '../../global.dart' as global;

bool? check;

int pg = 0;

int checkCircle2(){
  if(global.cid == ''){
    return 2;
  }
  else{
    return 1;
  }
}

Future<void> createActivities(cid) async{
  HttpsCallable updateAct = FirebaseFunctions.instance.httpsCallable('activity-createActivityDoc');
  await updateAct.call(<String,dynamic>{
    'cid': cid,
  });
}

Future<void> postActions(cid) async{
  HttpsCallable postActions = FirebaseFunctions.instance.httpsCallable('actions-postActions');
  await postActions.call(<String,dynamic>{
    'circleID': cid,
    'actions': global.list,
  });
}

Future<void> updateCircle(cid)async{
  HttpsCallable updateCirc = FirebaseFunctions.instance.httpsCallable('user-updateUserCircle');
  await updateCirc.call(<String,dynamic>{
    'cid': cid,
  });
}

void sending_SMS(String msg, List<String> list_receipents) async {
  String send_result = await sendSMS(message: msg, recipients: list_receipents, sendDirect: true)
      .catchError((err) {
    print(err);
  });
  print(send_result);
}
Future<int> checkCircle() async{
  int rval=0;
  final user = FirebaseAuth.instance.currentUser;
  HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
  await getCircleUID.call({
    'phno': user!.phoneNumber,
  }).then((resp)=>{
    print(resp.data),
    if(resp.data["cid"]!=null) {rval = 1,}else {rval = 2,},
  });
  return rval;
}

class ContactBookScreen extends StatelessWidget {
  const ContactBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkCircle();
    return const Scaffold(
      body: ContactBook(),
    );
  }
}

class ContactBook extends StatelessWidget {
  const ContactBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        Heading(),
        Expanded(
          child: ContactList2(),
        )
      ],
    );
  }
}


class Heading extends StatefulWidget {
  const Heading({Key? key}) : super(key: key);

  @override
  State<Heading> createState() => _HeadingState();
}

class _HeadingState extends State<Heading> {
  Future<void> createCircle(phno) async{
    final user = FirebaseAuth.instance.currentUser;
    HttpsCallable createCircle = FirebaseFunctions.instance.httpsCallable('circle-createCircle');
    final response = await createCircle.call(<String,dynamic>{
      'createdBy': user!.uid,
      'phNo': user.phoneNumber,
      'lovedOne': phno,
    }).then((resp)=>{
      print(resp.data),
    });
    // print(response.data);
  }
  static String phno = "";
  static List<String> phnos = [];
  static String lovedOneName = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // checkCircle().then((resp)=>{
    //   if(mounted){
    //     setState((){
    //       pg = resp;
    //     })
    //   }
    // });
    pg = checkCircle2();
  }
  @override
  Widget build(BuildContext context) {
    // print('careTaker${selectCareTakers}');
    // print('LovedOne${selectLovedOne}');
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 50, 0, 10),
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children:<Widget>[
          Align(
            alignment: const Alignment(-0.9,0),
            child: TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(71, 87, 233, 1),
                ),
              ),
            ),
          ),
          pg == 2?const Align(
            alignment: Alignment.center,
            child: Text(
              'Add Loved One',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color.fromRGBO(131, 131, 131, 1),
              ),
            )
          ):const SizedBox(),
          pg == 1?const Align(
              alignment: Alignment.center,
              child: Text(
                'Add Care Takers',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Color.fromRGBO(131, 131, 131, 1),
                ),
              )
          ):const SizedBox(),
          pg == 2? Align(
            alignment: const Alignment(0.9,0),
            child: TextButton(
              onPressed: (){
                // print(_HeadingState.phno);
                if(_HeadingState.phno!=""){
                  createCircle(_HeadingState.phno).then((value){
                    print('hello');
                    getCircle().then((val)=>{
                      print(val["circle"]),
                      updateCircle(val["circle"]).then((rval)=>{
                        createActivities(val['circle']).then((resp)=>{
                          addActivity(val['circle'], 'Created Circle').then((resp2)=>{
                            global.cid = val["circle"],
                            postActions(val['circle']).then((resp3)=>{
                              sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', [_HeadingState.phno]),
                              Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                            })
                          })
                        })
                      })
                    });
                  });
                }else{

                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(71, 87, 233, 1),
                ),
              ),
            )
          ):const SizedBox(),
          pg == 1? Align(
              alignment: const Alignment(0.9,0),
              child: TextButton(
                onPressed: (){
                  // print(_HeadingState.phnos);
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final user = auth.currentUser;
                  String phno = user!.phoneNumber!;
                  // sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', ['9148009365']);
                  sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', _HeadingState.phnos);
                  // HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
                  // getCircleUID.call(<String,dynamic>{
                  //   'phno': phno,
                  // }).then((resp){
                    HttpsCallable inviteMembers = FirebaseFunctions.instance.httpsCallable('circle-inviteMembers');
                    print(_HeadingState.phnos);
                    inviteMembers.call(<String,dynamic>{
                      'circleID': global.cid,
                      'members': _HeadingState.phnos,
                    }).then((response){
                      print(response.data);
                      addActivity(global.cid, "Members invited");
                      Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false);
                      // Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false);
                    });

                  // });
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(71, 87, 233, 1),
                  ),
                ),
              )
          ):const SizedBox(),
        ]
      ),
    );
  }
}





class ContactList2 extends StatefulWidget {
  const ContactList2({Key? key}) : super(key: key);

  @override
  State<ContactList2> createState() => _ContactList2State();
}

class _ContactList2State extends State<ContactList2> {


  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  // List<Contact> contacts = [];
  // List<Contact> contactsFiltered = [];
  List all_contacts= [];
  List filtered_contacts = [];
  int rlist=0;
  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      _HeadingState.phno = searchController.text;
      filterContacts();
    });
    rlist = checkCircle2();
    setState(() {

    });
    // checkCircle().then((val){
    //   rlist = val;
    //   if(mounted){
    //     setState(() {
    //
    //     });
    //   }
    // });
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  filterContacts(){
    // List<Contact> allContacts = [];
    List get_all_contacts = [];
    get_all_contacts.addAll(all_contacts);
    // print(get_all_contacts);
    if(searchController.text!= ''){
      if(_isNumeric(searchController.text)) {
        get_all_contacts.retainWhere((contact){
          String searchNumber = searchController.text;
          if(contact.phones.length>0){
            if(contact.phones![0].replaceAll(' ','').contains(searchNumber.replaceAll(' ',''))){
              return true;
            }
          }
          // for (var element in contactNumber) {
          //   if(element.value!.contains(searchNumber)){
          //     return true;
          //   }
          // }
          return false;
        });
      }
      else{
        get_all_contacts.retainWhere((contact){
          String searchTerm = searchController.text.toLowerCase();
          String contactName = contact.displayName!.toLowerCase();
          return contactName.contains(searchTerm);
        });
      }
    }
    if(mounted){
      setState(() {
        filtered_contacts = get_all_contacts;
      });
    }
  }
  getAllContacts() async{
    // List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    List getContacts = await FastContacts.allContacts;
    if(mounted){
      setState(() {
        all_contacts = getContacts;
        isLoading = false;
      });
    }
  }
  static const unselected = Color.fromRGBO(255, 255, 255, 1);
  static const selected = Color.fromRGBO(239, 241, 253, 1);
  int num = -1;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    bool searching = searchController.text.isNotEmpty;
    return isLoading == true?
     LoadingAnimationWidget.inkDrop(
          color:Colors.white,
          size:25,
        )
        :rlist==1?Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Find Contact',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                ),
              )
          ),
        ),

        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: searching==true? filtered_contacts.length : all_contacts.length,
              itemBuilder:(BuildContext context, int index){
                dynamic contact = searching==true? filtered_contacts[index]:all_contacts[index];

                late Future<Uint8List?> _imageFuture;
                // _imageFuture = FastContacts.getContactImage(filtered_contacts[index].id);
                _imageFuture = searching == true? FastContacts.getContactImage(filtered_contacts[index].id) : FastContacts.getContactImage(all_contacts[index].id);
                if(contact.phones!.isNotEmpty){
                  return Container(
                    margin: EdgeInsets.fromLTRB(25*width/360, 0, 25*width/360, 0),
                    decoration:const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if(contact.phones!.isNotEmpty){
                          if(_HeadingState.phnos.contains(contact.phones!.elementAt(0)!)){
                            _HeadingState.phnos.remove(contact.phones!.elementAt(0)!);
                          }else{
                            _HeadingState.phnos.add(contact.phones!.elementAt(0)!) ;
                          }
                          // print(index);
                          num=index;
                          if(mounted){
                            setState((){
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        backgroundColor: contact.phones!.isNotEmpty &&contact.phones!.elementAt(0)!=null&& !_HeadingState.phnos.contains(contact.phones!.elementAt(0))? unselected:selected,
                        // backgroundColor: const Color.fromRGBO(245, 245, 245, 0),
                      ),
                      child: ListTile(
                          title: Text(
                              contact.displayName!,
                              style: TextStyle(
                                fontSize: 18*width/360,      // idhar width kar
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        leading: FutureBuilder<Uint8List?>(
                        future: _imageFuture,
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
                            radius: 25,
                            child: Text(
                                searching == true? filtered_contacts[index].displayName[0] : all_contacts[index].displayName[0],
                                style: TextStyle(
                                    fontSize: 18*width/360
                                )
                            ),
                          ),
                        ),

                      ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }
          ),
        )
      ],
    ):Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Find Contact',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                ),
              )
          ),
        ),

        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: searching==true? filtered_contacts.length : all_contacts.length,
              itemBuilder:(BuildContext context, int index){
                dynamic contact = searching==true? filtered_contacts[index]:all_contacts[index];
                if(contact.phones!.isNotEmpty){
                  late Future<Uint8List?> _imageFuture;
                  // _imageFuture = FastContacts.getContactImage(filtered_contacts[index].id);
                  _imageFuture = searching == true? FastContacts.getContactImage(filtered_contacts[index].id) : FastContacts.getContactImage(all_contacts[index].id);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    decoration:const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if(contact.phones!.isNotEmpty){
                          _HeadingState.phno = contact.phones!.elementAt(0)!;
                          // _HeadingState.lovedOneName = contact.displayName;
                          // _HeadingState.lovedOneName = contact.dis
                          num=index;
                          if(mounted){
                            setState((){
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        backgroundColor: contact.phones!.isNotEmpty &&contact.phones!.elementAt(0)!=null&& contact.phones!.elementAt(0) != _HeadingState.phno? unselected:selected,
                        // backgroundColor: const Color.fromRGBO(245, 245, 245, 0),
                      ),
                      child: ListTile(
                          title: Text(
                              contact.displayName!,
                              style: TextStyle(
                                fontSize: 18*width/360,
                                fontWeight: FontWeight.w500,
                              )
                          ),
                          leading: FutureBuilder<Uint8List?>(
                            future: _imageFuture,
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
                                radius: 25,
                                child: Text(
                                    searching == true? filtered_contacts[index].displayName[0] : all_contacts[index].displayName[0],
                                    style: TextStyle(
                                        fontSize: 18*width/360
                                    )
                                ),
                              ),
                            ),

                          ),
                      ),
                    ),
                  );
                }
                else{
                  return const SizedBox();
                }
              }
          ),
        )
      ],
    );
  }
}