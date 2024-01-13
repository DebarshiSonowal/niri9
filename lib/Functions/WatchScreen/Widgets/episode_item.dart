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
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: (item.id == currentVideoId)
                ? Constants.thirdColor
                : Colors.transparent,
            width: 0.5.w,
          )),
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
    );
  }
}