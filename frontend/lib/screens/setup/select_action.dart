
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../setup/add_loved_one.dart' as a_l_l;

import '../../global.dart' as global;

class SelectActionScreen extends StatelessWidget {
  const SelectActionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SelectAction(),
    );
  }
}

class SelectAction extends StatelessWidget {
  const SelectAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 16*height/740, 0, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 15*height/740),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.black12,
              )
            )
          ),
          child:Stack(
            children: <Widget>[
              Align(
                alignment: const Alignment(-0.9,0),
                child: Container(
                  width: 36*width/360,
                  height:18*height/740,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      minimumSize: const Size(0,0),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: const Color.fromRGBO(71, 87, 233, 1),
                        fontSize: 16*width/360,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const  EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(
                      'Actions',
                      style: TextStyle(
                        color: const Color.fromRGBO(131, 131, 131, 1),
                        fontSize: 18*width/360,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
              ),
            ],
          )
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 18*height/740, 0, 0),
          child: Text(
            "Select your loved one's experience",
            style: TextStyle(
              fontSize: 16*width/360,
              fontWeight: FontWeight.w600,
            )
          )
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 20*height/740, 0, 8*height/740),
          child: Text(
            'SELECTED',
            style: TextStyle(
              fontSize: 14*width/360,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(189, 191, 193, 1),
            ),
          )
        ),
        const Actions(),
      ],
    );
  }
}

class Actions extends StatefulWidget {
  const Actions({Key? key}) : super(key: key);

  @override
  State<Actions> createState() => _ActionsState();
}

class _ActionsState extends State<Actions> {

  FirebaseFunctions functions = FirebaseFunctions.instance;

  bool isLoading = true;
  List<dynamic> actionsTrue =[];
  List<dynamic> actionsFalse =[];

  void getActions() async {
    // String getActionsUrl = "${url.api}/getActions";
    try{
      // String token = await FirebaseAuth.instance.currentUser!.getIdToken();
      // Map<String, String> headers = {
      //   "Content-Type": "application/json",
      //   "Accept": "application/json",
      //   "token": token,
      // };
      // final uri = Uri.parse('${url.api}/getActions');
      // final response = await get(uri,headers: headers);
      HttpsCallable getActions = FirebaseFunctions.instance.httpsCallable('actions-getActions');
      getActions.call().then((response)=>{
        actionsTrue = response.data["all_actions_true"].toList(),
        actionsFalse = response.data["all_actions_false"].toList(),
        setState(() {
          isLoading = false;
        }),
      }).catchError((err)=>{
        print(err)
      });
      // final response = await getActions.call();
      // Map<String,dynamic> jsonData;
      // jsonData = response.data;
      // setState(() {
      //   actionsTrue = jsonData["all_actions_true"].toList();
      //   actionsFalse = jsonData["all_actions_false"].toList();
      // });
    }catch(err){
      print(err);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    getActions();
    super.initState();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return isLoading == true?
    LoadingAnimationWidget.inkDrop(
      color:Colors.white,
      size:50*width/360,
    ):ListView(
      shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // <-- this will disable scroll
          shrinkWrap: true,
          itemCount: actionsTrue.length,
          itemBuilder: (context,index){
            return Container(
              margin: EdgeInsets.fromLTRB(20*width/360, 0, 20*width/360, 8*height/740),
              // padding: const EdgeInsets.fromLTRB(0,10,0,10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(239, 241, 253, 0.3),
                border: Border.all(
                  color: const Color.fromRGBO(71, 87, 233, 1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children:[
                  Container(
                    margin: EdgeInsets.fromLTRB(20*width/360,0,0,0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        actionsTrue[index]["name"],
                        style: TextStyle(
                          color:Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18*width/360,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(1,0),
                    child: IconButton(
                      onPressed: (){
                        dynamic temp = actionsTrue.removeAt(index);
                        temp["select"] = false;
                        actionsFalse.insert(0, temp);
                        setState(() {
                        });
                      },
                      icon: Icon(
                        Icons.remove_circle_outlined,
                        color: const Color.fromRGBO(132, 140, 207, 1),
                        size: 18*width/360,
                      ),
                    ),
                  ),
                ]

              ),
              );
          }
        ),
        Container(
            margin: EdgeInsets.fromLTRB(20*width/360, 16 *height/740, 0, 8*height/740),
            child: Text(
              'AVAILABLE',
              style: TextStyle(
                fontSize: 14*width/360,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(189, 191, 193, 1),
              ),
            )
        ),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: actionsFalse.length,
            itemBuilder: (context,index){
              return Container(
                margin: EdgeInsets.fromLTRB(20*width/360, 0, 20*width/360, 8*height/740),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(239, 241, 253, 0.3),
                  border: Border.all(
                    color: const Color.fromRGBO(210, 215, 211,1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children:[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20*width/360,0,0,0),
                        child: Text(
                          actionsFalse[index]["name"],
                          style: TextStyle(
                            color:Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18*width/360,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(1,0),
                      child: IconButton(
                        onPressed: (){
                          dynamic temp = actionsFalse.removeAt(index);
                          temp["select"] = true;
                          actionsTrue.insert(actionsTrue.length, temp);
                          setState(() {
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          color: const Color.fromRGBO(71, 87, 233, 1),
                          size: 18*width/360,
                        )
                      ),
                    )
                  ]
                ),
              );

            }
        ),
        Container(
            margin: EdgeInsets.fromLTRB(20*width/360,40*height/740,20*width/360,0),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ElevatedButton(
                onPressed: (){
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final user = auth.currentUser;
                  String phno = user!.phoneNumber!;
                  global.list = actionsTrue;
                  Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false);
                  // HttpsCallable getCircleUID = FirebaseFunctions.instance.httpsCallable('circle-getCircleUID');
                  // getCircleUID.call(<String,dynamic>{
                  //   'phno': phno,
                  // }).then((resp){
                  //   HttpsCallable postActions = FirebaseFunctions.instance.httpsCallable('actions-postActions');
                  //   postActions.call(<String,dynamic>{
                  //     'circleID': resp.data["cid"],
                  //     'actions': actionsTrue,
                  //   }).then((response){
                  //     // Navigator.pushNamed(context,'/contact_book_screen');
                  //     global.cid = resp.data['cid'];
                  //     Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false);
                  //   });
                  // });
                },
                child: Container(
                  margin:EdgeInsets.fromLTRB(0, 20*height/740, 0, 20*height/740),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18*width/360,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
            )
        ),
      ]

    );
  }
}

