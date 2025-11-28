import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class TrailerWidget extends StatefulWidget {
  const TrailerWidget({super.key, required this.url});

  final String url;

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  @override
  void initState() {
    super.initState();
    initializePlayer(widget.url);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 20.h,
      color: Colors.black,
      child: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(),
      ),
    );
  }

  Future<void> initializePlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
    );
    setState(() {});
  }
}
