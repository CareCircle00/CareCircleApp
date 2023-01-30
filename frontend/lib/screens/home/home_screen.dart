import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


bool isLoading = true;
bool isLoading2 = true;


List<Contact>contacts = [];

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
  for (var element in contacts) {
    // print(element.phones!.elementAt(0).value.toString());
    if(element.phones!.length!=0 && element.phones!.elementAt(0).value.toString() == contact){
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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getCircle().then((val)=>{
      getAllContacts(),
      if(mounted){
        print('val:$val'),
        setState(() {
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
    return ListView(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children:[
            const Align(
              alignment: Alignment(0,0),
              child: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 18,
                    color:Color.fromRGBO(131, 131, 131, 1),
                  )
              ),
            ),
            Align(
              alignment: const Alignment(0.95,0),
              child: TextButton(
                  onPressed: (){
                    print('pressed');
                  },
                  child: const Text(
                      'Help',
                      style: TextStyle(
                        fontSize: 16,
                        color:Color.fromRGBO(71, 87, 233, 1),
                      )
                  )
              ),
            ),
          ],
        ),
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
                    //  CircleAvatar(
                    //     radius: 25,
                    //     child: Text('C'),
                    //   )
                    ind != -1 && contacts[ind!].avatar!=null && contacts[ind!].avatar!.isNotEmpty?
                    CircleAvatar(
                      backgroundImage: MemoryImage(contacts[ind!].avatar!),
                      radius: 35,
                    ):
                    ind!=-1?CircleAvatar(
                      radius: 35,
                      child: Text(contacts[ind!].initials()),
                    ): const SizedBox()

                )    : const SizedBox()
                // child: CircleAvatar(
                //   radius: 35,
                //   child: Text(
                //       'C',
                //       style: TextStyle(
                //         fontSize: 20,
                //       )
                //   ),
                // ),
              ),
              Align(
                alignment: const Alignment(0.25,0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Last online',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: (){
                            print('Some more');
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(25,45,227,0.7 ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              )
                          ),
                          child: const Text(
                            'Ask if something is needed',
                            // style:
                          )
                      ),
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
                    child: const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                        child: const Text(
                          'Thursday, 3 Nov',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                    )
                )
              ],
            )
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20,20,0,0),
                    child: const Text(
                      'Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                        child: TextButton(
                            onPressed: (){
                              print('add');
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 16
                              ),
                            )
                        )
                    )
                )
              ],
            )
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20,20,0,0),
                    child: const Text(
                      'Last alerts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                        child: TextButton(
                            onPressed: (){
                              print('add');
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 16
                              ),
                            )
                        )
                    )
                )
              ],
            )
        )
      ],
    );
  }
}