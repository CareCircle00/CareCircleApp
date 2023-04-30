import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> addActivity(String cid,String activity)async{
  final user = FirebaseAuth.instance.currentUser;
  final uid = user!.uid;
  final ph = user.phoneNumber;
  bool rval = false;
  HttpsCallable addAct = FirebaseFunctions.instance.httpsCallable('activity-addActivity');
  await addAct.call(<String,dynamic>{
    'uid':uid,
    'cid':cid,
    'activity':activity,
    'timestamp': DateTime.now().toString(),
    'ph':ph
  }).then((resp)=>{
    rval = true,
  });
  return rval;
}