import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:native_video_view/native_video_view.dart';
import 'package:video_player/video_player.dart';

class Video extends StatelessWidget {
  const Video({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: VideoPlayerScreen(),
    );
  }
}

// Future<void> newUser()async{
//   final auth = FirebaseAuth.instance;
//   final user = auth.currentUser;
//   if(user!=null){
//     final ph = user!.phoneNumber!;
//   }
//   // HttpsCallable newUser = FirebaseFunctions.instance.httpsCallable('user-createUser');
//   // newUser.call(<String,dynamic>{
//   //   "ph":ph,
//   // }).then((resp)=>{
//   //   print(resp.data),
//   // });
// }

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  // @override
  // void initState() {
  //   _controller = VideoPlayerController.network(
  //     // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //     'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'
  //   );
  //   _initializeVideoPlayerFuture = _controller!.initialize().then((value)=>{
  //     _controller?.addListener(() {
  //       if(mounted){
  //         if(_controller!.value.position == _controller!.value.duration){
  //           if(mounted){
  //             Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false);
  //           }
  //         }
  //       }
  //     })
  //   });
  //
  //
  //   _controller!.setLooping(false);
  //   _controller!.play();
  //
  //   // newUser();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What is Care Circle'),
        actions: [
          IconButton(
            icon: Text(
              "Skip",
              // style: Theme.of(context).textTheme.button.apply(
              //   color: Theme.of(context).appBarTheme.actionsIconTheme.color,
              // ),
            ),
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false);
            },
          ),
        ]
      ),
      body: Container(
        alignment: Alignment.center,
        child: NativeVideoView(
          keepAspectRatio: true,
          showMediaController: true,
          onCreated: (controller) {
            controller.setVideoSource(
              'assets/videos/intro_video.mp4',
              sourceType: VideoSourceType.asset,
            );
          },
          onPrepared: (controller, info) {
            controller.play();
          },
          onError: (controller, what, extra, message) {
            print('Player Error ($what | $extra | $message)');
          },
          onCompletion: (controller) {
            // print('Video completed');
            Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false);
          },
          onProgress: (progress, duration) {
            // print('$progress | $duration');
          },
        ),
      ),
    );
  }



  // Widget build(BuildContext context) {
  //
  //   @override
  //   void dispose() {
  //     _controller!.dispose();
  //
  //     super.dispose();
  //   }
  //   return FutureBuilder(
  //     future: _initializeVideoPlayerFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         final width = MediaQuery.of(context).size.width;
  //         final height = MediaQuery.of(context).size.height;
  //         return ListView(
  //           physics: const NeverScrollableScrollPhysics(),
  //           children: [
  //             Stack(
  //               alignment: Alignment.center,
  //               children: <Widget>[
  //                 Align(
  //                   alignment: Alignment.center,
  //                   child: Container(
  //                     margin: EdgeInsets.fromLTRB(10*width/360, 0, 0, 0),
  //                     child: Text(
  //                       'What is care Circle?',
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: 20*width/360,
  //                         fontWeight: FontWeight.w600
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Align(
  //                   alignment: Alignment.centerRight,
  //                   child: Container(
  //                     margin: EdgeInsets.fromLTRB(0, 0, 0.001*width, 0),
  //                     child: TextButton(
  //                       onPressed: (){
  //                         _controller!.pause().then((rval)=>{
  //                           Navigator.of(context).pushNamedAndRemoveUntil('/splash_screen', (Route<dynamic> route) => false),
  //                         });
  //                       },
  //                       child: const Text(
  //                         'Skip',
  //                         style: TextStyle(
  //                         ),
  //                       )
  //                     ),
  //                   ),
  //                 )
  //               ],
  //             ),
  //             Container(
  //               margin: EdgeInsets.fromLTRB(0, 80*height/740, 0, 0),
  //               child: SizedBox(
  //                 height: 400*height/740,
  //                 width: 450*width/360,
  //                 child: AspectRatio(
  //                   aspectRatio: _controller!.value.aspectRatio,
  //                   child: VideoPlayer(_controller!),
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.fromLTRB(0, 10*height/740, 0, 0),
  //               child: FloatingActionButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     _controller!.value.isPlaying
  //                         ? _controller!.pause()
  //                         : _controller!.play();
  //                   });
  //                 },
  //                 child: Icon(
  //                   _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       } else {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //     },
  //   );
  // }
}