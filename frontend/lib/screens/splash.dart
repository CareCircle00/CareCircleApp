import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/screens/contact_book.dart';

import '../global.dart' as global;

import '../helper/user.dart' as user_helper;

////////////////////////////////////////////////////////////////////////

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
  }).then((resp)=>{
    print(resp.data),
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
Future<void> updateCircle(cid)async{
  HttpsCallable updateCirc = FirebaseFunctions.instance.httpsCallable('user-updateUserCircle');
  await updateCirc.call(<String,dynamic>{
    'cid': cid,
  });
}

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















//////////////////////////////////////////////////////////////////




Future<String> getCirc()async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber;
  String cid = "";
  int l =0;
  HttpsCallable getCirc = FirebaseFunctions.instance.httpsCallable('circle-getCircleUnacceptedUID');
  getCirc.call(<String,dynamic>{
    'phno':ph
  }).then((resp)=>{
    print(resp.data),
    if(resp.data["cid"]!=null){
      cid=resp.data["cid"],
    }
  });
  return cid;
}


Future<bool> updateMember()async{
  final user = FirebaseAuth.instance.currentUser!;
  final uid = user.uid;
  final phno = user.phoneNumber;
  bool rval = false;
  HttpsCallable ch = FirebaseFunctions.instance.httpsCallable('circle-checkIfMember');
  await ch.call(<String,dynamic>{
    'ph': phno
  }).then((r)=>{
    print('this:${r.data}'),
    print('this:${r.data["length"]}'),
    if(r.data["length"] == 1){
      rval = true
    }
    else{
      rval = false
    }
  });
  return rval;
}

Future<bool> checkSetUp()async{
  bool rval= false;
  HttpsCallable checkSetup1 = FirebaseFunctions.instance.httpsCallable('circle-checkSetup');
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  String phno = user!.phoneNumber!;
  await checkSetup1.call(<String,dynamic>{
    'phno':phno
  }).then((resp)=>{
    print('checksetup ${resp.data}'),
    // print(resp.data["setUpComplete"]["_fieldsProto"]["lovedOne"]["mapValue"]["fields"]),
    if(resp.data["length"] == 0){
      rval = false,
    }
    else if(resp.data["setUpComplete"]["_fieldsProto"]["setUpComplete"]["booleanValue"]==null || resp.data["setUpComplete"]["_fieldsProto"]["setUpComplete"]["booleanValue"] == false){
      rval = false,
    }
    else{
      rval = true,
    }
  });
  return rval;
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(auth.currentUser == null){
      Timer(const Duration(seconds:3),()=>{
        Navigator.of(context).pushNamedAndRemoveUntil('/login_screen', (Route<dynamic> route) => false),
      });
    }else{

      HttpsCallable checkUser = FirebaseFunctions.instance.httpsCallable('user-checkUser');
      checkUser.call(<String,dynamic>{

      }).then((resp)=>{
        print(resp.data),
        if(resp.data["user"]==null){
          newUser().then((resp)=>{

          }).then((resp)=>{
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
                      Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
                    })
                  })
                })
              }
            })
          }else{
            if(resp.data['user']['role']=='AsSWxqtDqEJLBGPXsgED'){
              Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
            }else if(resp.data['user']['role']=='m4PbOt884WWZwcAeR9OA'){
              // Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
              checkSet(resp.data["user"]["circle"]).then((r5)=>{
                if(r5 == true){
                  Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
                }else{
                  Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
                }
              })
            }
          }
          // if(resp.data['user']['role'] == null){
          //   checkRole().then((rval)=>{
          //     if(rval == ''){
          //       updateRole('m4PbOt884WWZwcAeR9OA')
          //     }
          //     else{
          //       updateRole('AsSWxqtDqEJLBGPXsgED')
          //     }
          //   })
          // }else{
          //   if(resp.data['user']['circle']==null){
          //     checkUnacceptedMember().then((rval)=>{
          //       if(rval==''){
          //         Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
          //       }else{
          //         updateCircle(rval).then((r)=>{
          //           //still update the acceptance status here
          //           //rval has the circle id
          //           removeAcceptance(rval).then((ret1)=>{
          //             updateAcceptance(rval).then((ret)=>{
          //               Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
          //             })
          //           })
          //         }),
          //       }
          //     })
          //   }else{
          //     Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
          //   }
          // },
        }
      });
    }
  }
  // initState()  {
  //   super.initState();
  //   final user = auth.currentUser;
  //
  //   if(user ==null){
  //     Timer(const Duration(seconds:3),()=>{
  //       Navigator.of(context).pushNamedAndRemoveUntil('/login_screen', (Route<dynamic> route) => false),
  //     });
  //   }else{
  //     // user_helper.addUser(user.uid, "");
  //     String ph = user.phoneNumber!;
  //     HttpsCallable checkUser = FirebaseFunctions.instance.httpsCallable('role-checkLovedOneNumber');
  //     checkUser.call(<String,dynamic>{
  //       'ph':ph
  //     }).then((r){
  //       if(r.data["phs"].length == 0){
  //         HttpsCallable newUser = FirebaseFunctions.instance.httpsCallable('user-newUser');
  //         newUser.call(<String,dynamic>{
  //           'uid':user.uid,
  //           'role':"m4PbOt884WWZwcAeR9OA"
  //         }).then((r)=>{
  //           print('r:${r.data}'),
  //           if(r.data["message"] == 'User doc exists!'){
  //               getCirc().then((retval)=>{
  //                 print(retval),
  //                 if(retval !=''){
  //                   Timer(const Duration(seconds:3),()=>{
  //                     checkSetUp().then((resp)=>{
  //                       if(resp == true){
  //                         Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
  //                       }
  //                       else{
  //                         Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
  //                       }
  //                     }),
  //                   })
  //                 }
  //                 else{
  //                   Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
  //                 }
  //               }),
  //           }else if(r.data["message"] == 'User Created Succesfully!'){
  //             updateMember().then((rval2)=>{
  //               Timer(const Duration(seconds:3),()=>{
  //                 checkSetUp().then((resp)=>{
  //                   print('rval2: $rval2'),
  //                   if(rval2 == true){
  //                     Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (Route<dynamic> route) => false)
  //                   }
  //                   else{
  //                     Navigator.of(context).pushNamedAndRemoveUntil('/add_loved_one_screen', (Route<dynamic> route) => false),
  //                   }
  //                 }),
  //               })
  //             }),
  //           },
  //         }).catchError((e)=>{});
  //       }
  //       else{
  //         HttpsCallable newUser = FirebaseFunctions.instance.httpsCallable('user-newUser');
  //         newUser.call(<String,dynamic>{
  //           'uid':user.uid,
  //           'role':"AsSWxqtDqEJLBGPXsgED"
  //         }).then((r)=>{
  //           print(r.data),
  //           if(r.data == 'User Created Successfully!'){
  //             print('Abhi add karna hai')
  //           },
  //           Timer(const Duration(seconds:3),()=>{
  //             Navigator.of(context).pushNamedAndRemoveUntil('/home_screen_loved_one', (Route<dynamic> route) => false)
  //           })
  //         }).catchError((e)=>{
  //           print(e),
  //         });
  //       }
  //     });
  //     global.user = user;
  //   }
  // }


  @override
  Widget build(BuildContext context) {

    return
        FractionallySizedBox(
          alignment:Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: SvgPicture.asset(
            'assets/svgs/splash_whitebg.svg',
            // 'assets/svgs/add_loved_ones_bg.svg'
          ),
        );
  }
}