import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_svg/svg.dart';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart';
// // import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../helper/user.dart' as user_helper;
import '../../global.dart' as global;

import './login.dart' as login_screen;

import 'package:pin_code_fields/pin_code_fields.dart';

// import '../urls.dart' as url;

Future<bool> checkSet(String cid)async{
  bool rval = false;
  HttpsCallable checkS = FirebaseFunctions.instance.httpsCallable('circle-checkSetup');
  await checkS.call(<String,dynamic>{
    'circle': cid,
  }).then((ret)=>{
    print(ret.data),
    rval = ret.data["setUpComplete"]
  });
  return rval;
}

Future<String> checkUnacceptedMember()async{
  String cid = '';
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber;
  HttpsCallable ch = FirebaseFunctions.instance.httpsCallable('user-checkUnacceptedMember');
  await ch.call(<String,dynamic>{
    'phno':ph
  }).then((rval)=>{
    print('here: ${rval.data}'),
    if(rval.data['circle']!=null){
      print(rval.data["circle"]),
      cid = rval.data['circle'],
    }
  });
  return cid;
}

Future<void> removeAcceptance(String cid)async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber!;
  HttpsCallable upAcc = FirebaseFunctions.instance.httpsCallable('user-removeUnacceptedMember');
  upAcc.call(<String,dynamic>{
    'cid':cid,
    "phno":ph,
  }).then((resp)=>{
    print(resp.data),
  });
}

Future<void> updateAcceptance(String cid)async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber!;
  HttpsCallable upAcc = FirebaseFunctions.instance.httpsCallable('user-updateAcceptance');
  upAcc.call(<String,dynamic>{
    'cid':cid,
    "phno":ph,
    'timestamp':DateTime.now().toString()
  }).then((resp)=>{
    print(resp.data),
  });
}

Future<void> updateCircle(cid)async{
  HttpsCallable updateCirc = FirebaseFunctions.instance.httpsCallable('user-updateUserCircle');
  await updateCirc.call(<String,dynamic>{
    'cid': cid,
  });
}
Future<void> updateLovedOneStatus(String cid)async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber!;
  HttpsCallable upAcc = FirebaseFunctions.instance.httpsCallable('circle-updateLovedOneStatus');
  upAcc.call(<String,dynamic>{
    'cid':cid,
    "phno":ph,
  }).then((resp)=>{
    print(resp.data),
  });
}

Future<String> checkRole()async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber;
  String cid = '';
  HttpsCallable checkCircle = FirebaseFunctions.instance.httpsCallable('user-checkLovedOne');
  await checkCircle.call(<String,dynamic>{
    'ph':ph
  }).then((resp)=>{
    print(resp.data["id"]),
    if(resp.data["id"] != ''){
      cid = resp.data["id"],
    }
  });
  return cid;
}

Future<void> updateRole(String role)async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber;
  HttpsCallable updRole = FirebaseFunctions.instance.httpsCallable('user-updateUserRole');
  updRole.call(<String,dynamic>{
    'role':role
  }).then((resp)=>{

  });
}

Future<void> newUser()async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber!;
  HttpsCallable newUser = FirebaseFunctions.instance.httpsCallable('user-createUser');
  newUser.call(<String,dynamic>{
    "ph":ph,
  }).then((resp)=>{
    print(resp.data),
  });
}

class CodeScreen extends StatelessWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Code(),
      );
  }
}


final FirebaseAuth auth = FirebaseAuth.instance;


class Code extends StatelessWidget {
  const Code({Key? key}) : super(key: key);

  static String keyImage = "assets/svgs/key.svg";
  static String otpEntered = '';

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 30*height/740, 0, 20*height/740),
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/key.png',
            scale:5,
          ),
        ),
        // Container(
        //   margin: const EdgeInsets.fromLTRB(0, 70, 0, 60),
        //   alignment: Alignment.center,
        //   child:SvgPicture.asset(
        //     'assets/svgs/key.svg',
        //     width: 60,
        //     height: 60,
        //     fit: BoxFit.fill,
        //   ),
        // ),
        Container(
          margin: EdgeInsets.fromLTRB(25*width/360, 0, 25*width/360, 20*height/740),
          alignment: Alignment.center,
          child: Text(
            'Enter code',
            style: TextStyle(
              fontSize: 34*width/360,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(25*width/360, 0, 45*width/360, 30*height/740),
          alignment: Alignment.center,
          child: Text(
            'We have just sent you the SMS with the 6-digit one-time password to ${login_screen.Login.phNo}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15*width/360,
              fontWeight: FontWeight.w500,
              color: Colors.black26,
            )
          )
        ),
        Container(
          margin: EdgeInsets.fromLTRB(25*width/360, 0, 25*width/360, 5*height/740),
          alignment: Alignment.center,
          child:PinCodeTextField(
            appContext: context,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5*width/360),
              fieldHeight: 50*height/740,
              fieldWidth: 50*width/360,
              // activeFillColor: Colors.white,
              // inactiveColor: Colors.white,
              inactiveFillColor: Colors.grey,
              inactiveColor: const Color.fromRGBO(227, 228, 229, 1),
              selectedColor: Colors.grey,
            ),
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.white,
            // enableActiveFill: true,
            // errorAnimationController: errorController,
            // controller: textEditingController,
            onCompleted: (v) {
              // print("Completed");

            },
            onChanged: (value) {
              // print(value);
              Code.otpEntered = value;
              // setState(() {
              //   currentText = value;
              // });
            },
            beforeTextPaste: (text) {
              // print("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          )
        ),
        Container(
          margin: EdgeInsets.fromLTRB(25*width/360, 0, 25*width/360, 0*height/740),
          alignment: Alignment.center,
          child:const SubmitButton(),
        ),
        Container(
          margin:EdgeInsets.fromLTRB(25*width/360, 0, 25*width/360, 0),
          alignment: Alignment.center,
          child:Text(
            "Haven't got SMS?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black26,
              fontSize: 16*width/360,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(25*width/360, 5*height/740, 25*width/360, 20*height/740),
          alignment: Alignment.center,
          child:const ResendCode(),
        ),
      ],
    );
  }
}

class SubmitButton extends StatefulWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  dynamic buttonBGColor;

  bool isPressed = false;
  bool errMessage = false;
  bool isLoading = false;

  static const activeColor = Color.fromRGBO(0, 140, 186, 1);
  static const inactiveColor = Color.fromRGBO(95, 88, 88, 1.0);


  @override
  void initState(){
    super.initState();
    setState(() {
      buttonBGColor = activeColor;
    });
  }

  void nextScreen(){
    Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20*height/740),
          child: ElevatedButton(
            onPressed: isPressed? null : () async {
              isPressed = true;
              setState(() {
                buttonBGColor = inactiveColor;
                isLoading = true;
              });
              try{
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: login_screen.Login.verify, smsCode: Code.otpEntered);
                await auth.signInWithCredential(credential);
                final user = auth.currentUser;
                HttpsCallable checkUser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
                checkUser.call(<String,dynamic>{

                }).then((resp)=>{
                  if(resp.data["user"]==null){
                    newUser().then((resp)=>{
                      checkRole().then((rval)=>{
                        if(rval == ''){
                          updateRole('m4PbOt884WWZwcAeR9OA').then((rval)=>{
                            checkUnacceptedMember().then((rval)=>{
                              if(rval==''){
                                Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
                              }else{
                                updateCircle(rval).then((r)=>{
                                  //still update the acceptance status here
                                  //rval has the circle id
                                  removeAcceptance(rval).then((ret1)=>{
                                    updateAcceptance(rval).then((ret)=>{
                                      global.cid = rval,
                                      Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                                    })
                                  })
                                }),
                              }
                            })
                            // Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
                          })
                        }
                        else{
                          updateRole('AsSWxqtDqEJLBGPXsgED').then((resp)=>{
                            updateLovedOneStatus(rval).then((r2)=>{
                              global.cid = rval,
                              Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
                            })
                          })
                        }
                      })
                    })
                  }
                  else{
                    if(resp.data['user']['circle'] == null){
                      checkRole().then((rval)=>{
                        if(rval == ''){
                          updateRole('m4PbOt884WWZwcAeR9OA').then((resp)=>{
                            checkUnacceptedMember().then((rval)=>{
                              if(rval==''){
                                Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
                              }else{
                                updateCircle(rval).then((r)=>{
                                  //still update the acceptance status here
                                  //rval has the circle id
                                  removeAcceptance(rval).then((ret1)=>{
                                    updateAcceptance(rval).then((ret)=>{
                                      global.cid = rval,
                                      Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                                    })
                                  })
                                }),
                              }
                            })
                          })
                        }
                        else{
                          updateRole('AsSWxqtDqEJLBGPXsgED').then((resp)=>{
                            updateLovedOneStatus(rval).then((r2)=>{
                              updateCircle(rval).then((r3)=>{
                                global.cid = rval,
                                Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
                              })
                            })
                          })
                        }
                      })
                    }else{
                      if(resp.data['user']['role']=='AsSWxqtDqEJLBGPXsgED'){
                        global.cid = resp.data['user']['circle'],
                        Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
                      }else if(resp.data['user']['role']=='m4PbOt884WWZwcAeR9OA'){
                        // Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                        checkSet(resp.data["user"]["circle"]).then((r5)=>{
                          if(r5 == true){
                            global.cid = resp.data['user']['circle'],
                            Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                          }else{
                            global.cid = resp.data['user']['circle'],
                            Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
                          }
                        })
                      }
                    }
                  }
                });
                // dynamic resp = user_helper.addUser(user!.uid, "");
                // HttpsCallable getActions = FirebaseFunctions.instance.httpsCallable('user-newUser');
                // getActions.call(<String,dynamic>{
                //   'uid':user!.uid,
                //   'role':"m4PbOt884WWZwcAeR9OA"
                // }).then((r)=>{print(r.data)}).catchError((e)=>{print(e)});

              }catch(err){
                print(err);
                errMessage = true;
                setState(() {

                });
              }
              isPressed = false;
              buttonBGColor = activeColor;
              isLoading = false;
              setState(() {

              });
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(400*width/360, 60*height/740),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10*width/360)
              ),
              backgroundColor: buttonBGColor,
            ),
            child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment:const Alignment(-0.4,0),
                        child: Opacity(
                          opacity: isLoading?1:0,
                          child: LoadingAnimationWidget.inkDrop(
                            color:Colors.white,
                            size:25*width/360,
                          ),
                          // child:LoadingAnimationWidget.twistingDots(
                          //   leftDotColor: const Color(0xFF1A1A3F),
                          //   rightDotColor: const Color(0xFFEA3799),
                          //   size: 25,
                          // ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Submit', style: TextStyle(fontSize: 20.0)
                        ),
                      ),
                  ]
            )
          ),
        ),
        Opacity(
          opacity: errMessage?1:0,
          child: Container(
            alignment: Alignment.center,
            child:Text(
              'Incorrect Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 18*width/360,
                fontWeight: FontWeight.w400,
              ),
            )
          )
        ),
      ]
    );
  }
}

class ResendCode extends StatefulWidget {
  const ResendCode({Key? key}) : super(key: key);

  @override
  State<ResendCode> createState() => _ResendCodeState();
}

class _ResendCodeState extends State<ResendCode> {

  bool resendMsg = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Container(
          margin:EdgeInsets.fromLTRB(0, 0, 0, 25*height/740),
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 18*width/360),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              // print('resend brother');
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: '+${login_screen.Login.countryCode} ${login_screen.Login.phNo}',
                verificationCompleted: (PhoneAuthCredential credential) {},
                verificationFailed: (FirebaseAuthException e) {},
                codeSent: (String verificationId, int? resendToken) {
                  login_screen.Login.verify = verificationId;
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
              );
              setState(() {
                resendMsg = true;
              });
            },
            child: const Text(
                'Resend Code',
                style:TextStyle(
                  fontWeight: FontWeight.w400,
                )
            ),
          ),
        ),
        SizedBox(
          width:200,
          child: Opacity(
            opacity: resendMsg?1:0,
            child: Text(
              'Code has been resent to ${login_screen.Login.phNo}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20*width/360,
                fontWeight: FontWeight.w500,
              )
            )
          ),
        ),
      ],
    );
  }
}
