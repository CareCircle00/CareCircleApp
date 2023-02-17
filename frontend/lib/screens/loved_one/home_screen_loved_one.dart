import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

List list = [
  "Call Peter",
  "I need medicine",
  "I need groceries",
  "Mood Detector",
  "Call Everyone"
];

Future<String> checkUser()async{
  final user = FirebaseAuth.instance.currentUser!;
  final uid = user.uid;
  String rval = '';
  HttpsCallable chuser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
  await chuser.call(<String,dynamic>{
    'uid':uid
  }).then((resp)=>{
    if(resp.data['user']['circle']!=null){
      rval = resp.data['user']['circle'],
    }
  });
  return rval;
}

Future<void> setMood(int m,String cid)async{
  HttpsCallable chmood = FirebaseFunctions.instance.httpsCallable('circle-changeMood');
  chmood.call(<String,dynamic>{
    'mood':m,
    'circleID': cid
  }).then((resp)=>{
  });
}

var parser = EmojiParser();

class Head extends StatelessWidget {
  const Head({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.fromLTRB(0,10*height/740,0,8*height/740),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20*height/740),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.2,
            color: Colors.grey,
          )
        )
      ),
      child: Stack(
        alignment: Alignment.center,
        children:[
          // Align(
          //   alignment: const Alignment(0,0),
          //   child: Text(
          //       'Home',
          //       style: TextStyle(
          //         fontSize: 18*width/360,
          //         color:const Color.fromRGBO(131, 131, 131, 1),
          //       )
          //   ),
          // ),
          // Align(
          //   alignment: const Alignment(0.95,0),
          //   child: TextButton(
          //       onPressed: (){
          //         print('help');
          //       },
          //       child: const Text(
          //           'Help',
          //           style: TextStyle(
          //             fontSize: 16,
          //             color:Color.fromRGBO(71, 87, 233, 1),
          //           )
          //       )
          //   ),
          // ),
        ],
      ),
    );
  }
}


class LovedOneHomeScreen extends StatefulWidget {
  const LovedOneHomeScreen({Key? key}) : super(key: key);

  @override
  State<LovedOneHomeScreen> createState() => _LovedOneHomeScreenState();
}

class _LovedOneHomeScreenState extends State<LovedOneHomeScreen> {
  @override
  String cid = '';
  bool isLoading3 = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser().then((resp){
      setState((){
        cid = resp;
        isLoading3 = false;
      });
    });
  }
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        const Head(),
        list.length%2==0?ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context,index){
            if(index%2!=0) {
              return const SizedBox();
            }else{
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10,10,10,10),
                      height: height*140/740,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            list[index],
                            style: TextStyle(
                              fontSize: 18*width/360,
                            ),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
                      // padding: EdgeInsets.only(left: 8.0),
                      height: 140*height/740,
                      child: ElevatedButton(
                          onPressed: () {},
                          child:Text(
                            list[index+1],
                            style: TextStyle(
                              fontSize: 18*width/360,
                              color: Colors.black
                            ),
                          )
                      ),
                    ),
                  )
                ],
              );
            }
          }
        ):ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context,index){
            if(index%2!=0 && index!= list.length-1) {
              return const SizedBox();
            }else if(index!= list.length-1){
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
                      height: 140*height/740,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        child: Text(
                          list[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18*width/360,
                            color: Colors.black
                          ),
                        )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10*width/360,10*height/740,10*width/360,10*height/740),
                      // padding: EdgeInsets.only(left: 8.0),
                      height: 140*height/740,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          HttpsCallable checkSetup = FirebaseFunctions.instance.httpsCallable('circle-changeMood');
                          checkSetup.call(<String,dynamic>{
                            'mood':3
                          });
                        },
                          child:Text(
                            list[index+1],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18*width/360,
                              color: Colors.black,
                            ),
                          )
                      ),
                    ),
                  )
                ],
              );
            }else{
              return Container(
                margin: EdgeInsets.fromLTRB(10*width/360, 10*height/740, 10*width/360, 0*height/740),
                height: 140*height/740,
                child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                    ),
                    child:Text(
                      list[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18*width/360,
                        color: Colors.black
                      ),
                    )
                ),
              );
            }
          },
        ),
        isLoading3 == true? SizedBox():Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: (){
                  setState(() {
                    isLoading3 = true;
                  });
                  setMood(5,cid).then((resp)=>{
                    setState((){
                      isLoading3=false;
                    })
                  });
                },
                // child: Text(parser.info('smiley').code)
                child: Text(
                  '😀',
                  style: TextStyle(
                    fontSize: 40*width/360,
                  ),
                )
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      isLoading3 = true;
                    });
                    setMood(4,cid).then((resp)=>{
                      setState((){
                        isLoading3=false;
                      })
                    });
                  },
                  // child: Text(parser.info('smiley').code)
                  child: Text(
                    '☺',
                    style: TextStyle(
                      fontSize: 40*width/360,
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      isLoading3 = true;
                    });
                    setMood(3,cid).then((resp)=>{
                      setState((){
                        isLoading3=false;
                      })
                    });
                  },
                  // child: Text(parser.info('smiley').code)
                  child: Text(
                    '🙂',
                    style: TextStyle(
                      fontSize: 40*width/360,
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      isLoading3 = true;
                    });
                    setMood(2,cid).then((resp)=>{
                      setState((){
                        isLoading3=false;
                      })
                    });
                  },
                  // child: Text(parser.info('smiley').code)
                  child: Text(
                    '🙁',
                    style: TextStyle(
                      fontSize: 40*width/360,
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      isLoading3 = true;
                    });
                    setMood(1,cid).then((resp)=>{
                      setState((){
                        isLoading3=false;
                      })
                    });
                  },
                  // child: Text(parser.info('smiley').code)
                  child : Text(
                    '😞',
                    style: TextStyle(
                      fontSize: 40*width/360,
                    ),
                  )
              ),
            ]
          )
        )
      ]
    );
  }
}
