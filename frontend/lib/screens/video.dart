import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatelessWidget {
  const Video({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoPlayerScreen(),
    );
  }
}

Future<void> newUser()async{
  final user = FirebaseAuth.instance.currentUser!;
  final ph = user.phoneNumber!;
  print(user);
  print(ph);
  // HttpsCallable newUser = FirebaseFunctions.instance.httpsCallable('user-createUser');
  // newUser.call(<String,dynamic>{
  //   "ph":ph,
  // }).then((resp)=>{
  //   print(resp.data),
  // });
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );
    _initializeVideoPlayerFuture = _controller!.initialize();


    _controller!.setLooping(false);
    _controller!.play();

    newUser();
    super.initState();
  }
  Widget build(BuildContext context) {

    @override
    void dispose() {
      _controller!.dispose();

      super.dispose();
    }
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}