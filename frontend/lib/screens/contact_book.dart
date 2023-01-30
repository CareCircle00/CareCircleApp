import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:frontend/screens/add_loved_one.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

bool? check;

int pg = 0;

Future<void> updateCircle(cid)async{
  HttpsCallable updateCirc = FirebaseFunctions.instance.httpsCallable('user-updateUserCircle');
  await updateCirc.call(<String,dynamic>{
    'cid': cid,
  });
}

void sending_SMS(String msg, List<String> list_receipents) async {
  String send_result = await sendSMS(message: msg, recipients: list_receipents)
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
      'phNo': user!.phoneNumber,
      'lovedOne': phno,
    }).then((resp)=>{
      print(resp.data),
    });
    // print(response.data);
  }
  static String phno = "";
  static List<String> phnos = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCircle().then((resp)=>{
      setState((){
        pg = resp;
      })
    });
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
                print('cancel');
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
                print(_HeadingState.phno);
                if(_HeadingState.phno!=""){
                  createCircle(_HeadingState.phno).then((value){
                    getCircle().then((val)=>{
                      print(val["circle"]),
                      updateCircle(val["circle"]).then((rval)=>{
                        Navigator.pushNamed(context,'/add_loved_one_screen'),
                      })
                    });
                  });
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
                  print(_HeadingState.phnos);
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final user = auth.currentUser;
                  String phno = user!.phoneNumber!;
                  // sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', ['9148009365']);
                  sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', _HeadingState.phnos);
                  HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
                  getCircleUID.call(<String,dynamic>{
                    'phno': phno,
                  }).then((resp){
                    HttpsCallable inviteMembers = FirebaseFunctions.instance.httpsCallable('circle-inviteMembers');
                    inviteMembers.call(<String,dynamic>{
                      'circleID': resp.data["cid"],
                      'members': _HeadingState.phnos,
                    }).then((response){
                      print(response.data);
                      Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false);
                      // Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false);
                    });

                  });
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
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  int rlist=0;
  @override
  void initState() {

    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
    checkCircle().then((val){
      rlist = val;
      setState(() {

      });
    });
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  filterContacts(){
    List<Contact> allContacts = [];
    allContacts.addAll(contacts);
    if(searchController.text.isNotEmpty){
      if(_isNumeric(searchController.text)) {
        allContacts.retainWhere((contact){
          String searchNumber = searchController.text;
          List<Item> contactNumber = contact.phones!;
          for (var element in contactNumber) {
            if(element.value!.contains(searchNumber)){
              return true;
            }
          }
          return false;
        });
      }
      else{
        allContacts.retainWhere((contact){
          String searchTerm = searchController.text.toLowerCase();
          String contactName = contact.displayName!.toLowerCase();
          return contactName.contains(searchTerm);
        });
      }
    }
    setState(() {
      contactsFiltered = allContacts;
    });
  }
  getAllContacts() async{
    List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = getContacts;
      isLoading = false;
    });
  }
  static const unselected = Color.fromRGBO(255, 255, 255, 1);
  static const selected = Color.fromRGBO(239, 241, 253, 1);
  int num = -1;
  @override
  Widget build(BuildContext context) {
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
              itemCount: searching==true? contactsFiltered.length : contacts.length,
              itemBuilder:(BuildContext context, int index){
                Contact contact = searching==true? contactsFiltered[index]:contacts[index];
                if(contact.phones!.isNotEmpty){
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
                          if(_HeadingState.phnos.contains(contact.phones!.elementAt(0).value!)){
                            _HeadingState.phnos.remove(contact.phones!.elementAt(0).value!);
                          }else{
                            _HeadingState.phnos.add(contact.phones!.elementAt(0).value!) ;
                          }
                          // print(index);
                          num=index;
                          setState((){
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        backgroundColor: contact.phones!.isNotEmpty &&contact.phones!.elementAt(0).value!=null&& !_HeadingState.phnos.contains(contact.phones!.elementAt(0).value)? unselected:selected,
                        // backgroundColor: const Color.fromRGBO(245, 245, 245, 0),
                      ),
                      child: ListTile(
                          title: Text(
                              contact.displayName!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              )
                          ),
                          leading: (contact.avatar != null && contact.avatar!.isNotEmpty)?
                          CircleAvatar(
                            backgroundImage: MemoryImage(contact.avatar!),
                            radius: 25,
                          ):
                          CircleAvatar(
                            radius: 25,
                            child: Text(
                              contact.initials(),
                              style: const TextStyle(
                              ),
                            ),
                          )
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
              itemCount: searching==true? contactsFiltered.length : contacts.length,
              itemBuilder:(BuildContext context, int index){
                Contact contact = searching==true? contactsFiltered[index]:contacts[index];
                if(contact.phones!.isNotEmpty){
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
                          _HeadingState.phno = contact.phones!.elementAt(0).value!;
                          // print(index);
                          num=index;
                          setState((){
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        backgroundColor: contact.phones!.isNotEmpty &&contact.phones!.elementAt(0).value!=null&& contact.phones!.elementAt(0).value != _HeadingState.phno? unselected:selected,
                        // backgroundColor: const Color.fromRGBO(245, 245, 245, 0),
                      ),
                      child: ListTile(
                          title: Text(
                              contact.displayName!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              )
                          ),
                          leading: (contact.avatar != null && contact.avatar!.isNotEmpty)?
                          CircleAvatar(
                            backgroundImage: MemoryImage(contact.avatar!),
                            radius: 25,
                          ):
                          CircleAvatar(
                            radius: 25,
                            child: Text(
                              contact.initials(),
                              style: const TextStyle(
                              ),
                            ),
                          )
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }
          ),
        )
      ],
    );
  }
}

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {


  TextEditingController searchController = TextEditingController();
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  filterContacts(){
    List<Contact> allContacts = [];
    allContacts.addAll(contacts);
    if(searchController.text.isNotEmpty){
      if(_isNumeric(searchController.text)) {
        allContacts.retainWhere((contact){
          String searchNumber = searchController.text;
          List<Item> contactNumber = contact.phones!;
          for (var element in contactNumber) {
            if(element.value!.contains(searchNumber)){
              return true;
            }
          }
          return false;
        });
      }
      else{
        allContacts.retainWhere((contact){
          String searchTerm = searchController.text.toLowerCase();
          String contactName = contact.displayName!.toLowerCase();
          return contactName.contains(searchTerm);
        });
      }
    }
    setState(() {
      contactsFiltered = allContacts;
    });
  }
  getAllContacts() async{
    List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = getContacts;
    });
  }
  static const unselected = Color.fromRGBO(255, 255, 255, 1);
  static const selected = Color.fromRGBO(239, 241, 253, 1);
  int num = -1;
  @override
  Widget build(BuildContext context) {
    bool searching = searchController.text.isNotEmpty;
    return Column(
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
              itemCount: searching==true? contactsFiltered.length : contacts.length,
              itemBuilder:(BuildContext context, int index){
                Contact contact = searching==true? contactsFiltered[index]:contacts[index];
                if(contact.phones!.isNotEmpty){
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
                          _HeadingState.phno = contact.phones!.elementAt(0).value!;
                          // print(index);
                          num=index;
                          setState((){
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        backgroundColor: contact.phones!.isNotEmpty &&contact.phones!.elementAt(0).value!=null&& contact.phones!.elementAt(0).value != _HeadingState.phno? unselected:selected,
                        // backgroundColor: const Color.fromRGBO(245, 245, 245, 0),
                      ),
                      child: ListTile(
                          title: Text(
                              contact.displayName!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              )
                          ),
                          leading: (contact.avatar != null && contact.avatar!.isNotEmpty)?
                          CircleAvatar(
                            backgroundImage: MemoryImage(contact.avatar!),
                            radius: 25,
                          ):
                          CircleAvatar(
                            radius: 25,
                            child: Text(
                              contact.initials(),
                              style: const TextStyle(
                              ),
                            ),
                          )
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }
          ),
        )
      ],
    );
  }
}