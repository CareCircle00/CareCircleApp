import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './circle_screen.dart' as circle_screen;
import '../../global.dart' as global;
import 'package:flutter_sms/flutter_sms.dart';

void sending_SMS(String msg, List<String> list_receipents) async {
  String send_result = await sendSMS(message: msg, recipients: list_receipents)
      .catchError((err) {
    print(err);
  });
  print(send_result);
}

List<dynamic> all_contacts = circle_screen.all_contacts;


// Future<void> getUser(String num)async{
//
// }

class Status extends StatelessWidget {
  const Status({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatusScreen(),
    );
  }
}

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    dynamic ret = circle_screen.CenterList.per;
    dynamic mem = circle_screen.CenterList.mem;
    print(mem);
    // print(circle_screen.all_contacts);

    late Future<Uint8List?> _imageFuture;
    if(ret!=-1){
      _imageFuture = FastContacts.getContactImage(all_contacts[ret].id);
    }

    return ListView(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 25*height/740),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1*height/740
              )
            )
          ),
          height: 50*height/740,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 15*width/360,
                      fontWeight: FontWeight.w500
                    )
                  ),
                )
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20*width/360
                  )
                ),
              ),
            ],
          ),
        ),
        ret!=-1?FutureBuilder<Uint8List?>(
          future: _imageFuture,
          builder: (context, snapshot) => Container(
            width: 90,
            height: 90,
            child: snapshot.hasData
                ?
            CircleAvatar(
              backgroundImage: MemoryImage(snapshot.data!),
              radius:90,
            )
            // Image.memory(snapshot.data!, gaplessPlayback: true)
                :
            CircleAvatar(
              radius: 90,
              child: Text(
                all_contacts[ret].displayName[0],
                style: const TextStyle(
                  fontSize: 30
                ),
              ),
            ),
          ),
        ):CircleAvatar(
        radius: 45,
          child: Text(
            mem["mapValue"]["fields"]["memberNumber"]["stringValue"][0],
            style: const TextStyle(
              fontSize: 30
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 10*height/740, 0, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children : [
                ret==-1?
                Text(
                  mem["mapValue"]["fields"]["memberNumber"]["stringValue"],
                  style: TextStyle(
                    fontSize: 24*width/360,
                  )
                ):
                Text(
                  all_contacts[ret].displayName,
                  style: TextStyle(
                    fontSize: 24*width/360,
                  )
                ),
                mem['mapValue']['fields']['status']['stringValue'] == 'Accepted'?
                Text(
                  mem['mapValue']['fields']['status']['stringValue'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18*width/360,
                    )
                )    :
                Text(
                    mem['mapValue']['fields']['status']['stringValue'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18*width/360,
                    )
                ),
              ]
          ),
        ),
        mem['mapValue']['fields']['status']['stringValue'] == 'Pending'?
        Container(
          margin: EdgeInsets.fromLTRB(0, 30*height/740, 0, 0),
          padding: EdgeInsets.fromLTRB(20*width/360, 0, 20*width/360, 0),
          child: ElevatedButton(
            onPressed: (){
              sending_SMS('This application I told you about is very simple, just install it and I will set everything up for you', [mem["mapValue"]["fields"]["memberNumber"]["stringValue"]]);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(25,45,227,0.7 ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                )
            ),
            child: const Text(
              'Resend Invite'
            )
          ),
        ):const SizedBox()
      ],
    );
  }
}