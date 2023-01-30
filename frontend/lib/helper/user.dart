import 'package:cloud_functions/cloud_functions.dart';

Future<HttpsCallableResult> addUser(String uid,var role) async{
  dynamic resp;
  HttpsCallable getActions = FirebaseFunctions.instance.httpsCallable('user-newUser');
  resp = await getActions.call(<String,dynamic>{
    'uid':uid,
    'role':"m4PbOt884WWZwcAeR9OA"
  }).then((r)=>{resp = r}).catchError((e)=>{print(e)});
  return resp;
}