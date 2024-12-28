import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';

class TrailerWidget extends StatefulWidget {
  const TrailerWidget({super.key, required this.url});

  final String url;

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  late CachedVideoPlayerPlusController _customVideoPlayerController;
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    _future = initiateVideoPlayer(widget.url);
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 20.h,
      color: Colors.black,
      child: FutureBuilder<bool>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Something went wrong"),
              );
            }
            return CachedVideoPlayerPlus(_customVideoPlayerController);
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Future<bool> initiateVideoPlayer(String url) async {
    debugPrint(url);
    _customVideoPlayerController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(
          "https://customer-edsfz57k0gqg8bse.cloudflarestream.com/4cd3574842ee86e0bff21ed6c9d61238/manifest/video.m3u8"),
    );
    await _customVideoPlayerController.initialize();
    _customVideoPlayerController.play();
    setState(() {});
    return true;
  }
}
