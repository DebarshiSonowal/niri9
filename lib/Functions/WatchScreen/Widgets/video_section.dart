import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:sizer/sizer.dart';

class VideoSection extends StatelessWidget {
  const VideoSection({
    super.key,
    required CustomVideoPlayerController customVideoPlayerController,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CustomVideoPlayerController _customVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          color: Colors.black,
          height: 28.h,
          width: double.infinity,
          child: CustomVideoPlayer(
            customVideoPlayerController: _customVideoPlayerController,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
          ),
          height: 4.h,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
               decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.05),
                 shape: BoxShape.circle,
               ),
                child: IconButton(
                  onPressed: () {
                    Navigation.instance.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigation.instance.goBack();
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
