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
      elevation: (item.id == currentVideoId) ? 10:1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
            (item.id == currentVideoId) ? Colors.white : Colors.transparent,
            width: (item.id == currentVideoId) ? 0.8.w : 0.1.w,
          ),
        ),
        child: CachedNetworkImage(
          imageUrl: item.profile_pic ?? "",
          fit: BoxFit.fill,
          // height: 10.h,
          width: 40.w,
          placeholder: (context, index) {
            return Image.asset(
              Assets.logoTransparent,
            ).animate();
          },
        ),
        // child: Text("${item.id} ${currentVideoId}"),
      ),
    );
  }
}
