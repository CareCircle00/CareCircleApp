import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
dynamic lovedOne;

List<Contact> contacts= [];
Future<dynamic> getCircle() async{
  dynamic rval = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  String phno = user!.phoneNumber!;
  HttpsCallable getCircle = FirebaseFunctions.instance.httpsCallable('circle-getCircleMembers');
  await getCircle.call(<String,dynamic>{
    'phno' : phno,
  }).then((response)=>{
    print(response.data),
    lovedOne = response.data["lovedOne"],
    rval = response.data["members"],
  });
  return rval;
}

// int getPerson(dynamic contact){
//   int temp = -1;
//   int i = 0;
//   for (var element in contacts) {
//     if(element.phones!.length!=0 && element.phones!.elementAt(0).value == contact["mapValue"]["fields"]["member"]["stringValue"]){
//       temp = i;
//     }
//     ++i;
//   }
//   return temp;
// }

int getPerson(dynamic contact){
  int temp = -1;
  int i = 0;
  for (var element in contacts) {
    if(element.phones!.length!=0 && element.phones!.elementAt(0).value == contact["mapValue"]["fields"]["memberNumber"]["stringValue"]){
      temp = i;
    }
    ++i;
  }
  return temp;
}


class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView(

      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 13),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5
              )
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const Align(
                alignment: Alignment.center,
                child:Text(
                  'Chats',
                  style:TextStyle(
                    color: Color.fromRGBO(131, 131, 131, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,

                  )
                )
              ),
              Align(
                alignment: const Alignment(-0.9,0),
                child: TextButton(
                  onPressed: ()async{
                    final auth = FirebaseAuth.instance;
                    await auth.signOut();
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  )
                )
              )
            ],
          )
        ),
        const Chats(),
      ],
    );
  }
}



class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  dynamic members=[];
  bool isLoading = true;
  bool isLoading2 = true;
  void getAllContacts() async{
    List<Contact> getContacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = getContacts;
      isLoading2 = false;
      // print(contacts[0].phones!.elementAt(0).value);
      // print(contacts[0].displayName![0]);
    });
  }
  @override
  void initState() {
    super.initState();
    getCircle().then((resp)=>{
      members = resp,
      getAllContacts(),
      setState(() {
        isLoading = false;
      }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true? Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: LoadingAnimationWidget.inkDrop(
        color:Colors.white,
        size:30,
      ),

    ) :isLoading == false && isLoading2==false?
    SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(245, 245, 245, 0.9),
              border: Border(
                  bottom: BorderSide(
                    color:Colors.grey,
                    width: 0.25,
                  )
              ),
            ),
            child: ElevatedButton(
                onPressed: (){

                },
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(245, 245, 245, 0.9),
                  foregroundColor: Colors.blueAccent,
                  elevation: 0,
                ),
                child: Row(
                  // alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment(-1,0),
                      child: CircleAvatar(
                        radius: 18,
                        child: Text('C'),
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10,0,0,0),
                      child: const Text(
                        'LovedOne',
                        // '${lovedOne["lovedOne"]["mapValue"]} (Loved One)',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]

                )
            ),
          ),
          ListView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context,index){
              print(members[index]);
              FirebaseAuth auth = FirebaseAuth.instance;
              final user = auth.currentUser;
              int ret = getPerson(members[index]);
              return ret==-1? SizedBox(): Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(245, 245, 245, 0.9),
                  border: Border(
                    bottom: BorderSide(
                      color:Colors.grey,
                      width: 0.25,
                    )
                  ),
                ),
                child: ElevatedButton(
                  onPressed: (){

                  },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(245, 245, 245, 0.9),
                      foregroundColor: Colors.blueAccent,
                      elevation: 0,
                    ),
                  child: Stack(
                    children: [
                      Align(
                          alignment: const Alignment(-1,0),
                          child: ret == -1? const SizedBox(): Row(
                            children: [
                              contacts[ret].avatar!=null && contacts[ret].avatar!.isNotEmpty?
                              CircleAvatar(
                                backgroundImage: MemoryImage(contacts[ret].avatar!),
                                radius: 18,
                              ):
                              CircleAvatar(
                                radius: 18,
                                child: Text(contacts[ret].initials()),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(10,0,0,0),
                                child: Text(
                                  // members[index]["mapValue"]["fields"]["member"]["stringValue"],
                                  contacts[ret].displayName!,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ]
                          )
                      ),
                    ]
                  )
                ),
              );
            },
          ),
        ],
      ),
    ):const SizedBox();
  }
}
