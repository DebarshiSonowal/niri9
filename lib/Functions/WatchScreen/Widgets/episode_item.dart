import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Constants/constants.dart';
import '../../../Models/video_details.dart';

class EpisodeItem extends StatelessWidget {
  const EpisodeItem({
    super.key,
    required this.item,
    required this.currentVideoId,
  });

  final VideoDetails item;
  final int currentVideoId;

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: (item.id == currentVideoId) ? 10.0 : 1.0,
      shadowColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
            (item.id == currentVideoId) ? Colors.white : Colors.transparent,
            width: (item.id == currentVideoId) ? 0.8.w : 0.1.w,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: item.profile_pic ?? "",
                fit: BoxFit.fill,
                // height: 10.h,
                filterQuality: (item.id == currentVideoId) ?FilterQuality.high:FilterQuality.low,
                width: 40.w,
                placeholder: (context, index) {
                  return Image.asset(
                    Assets.logoTransparent,
                  ).animate();
                },
              ),
              if (item.id != currentVideoId)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.7, sigmaY: 0.7),
                  child: Container(
                    color: Colors.transparent, // Adjust as needed
                  ),
                ),
            ],
          ),
        ),
        // child: Text("${item.id} ${currentVideoId}"),
      ),
    );
  }
}
