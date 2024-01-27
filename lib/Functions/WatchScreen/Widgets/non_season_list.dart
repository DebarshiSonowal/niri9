import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/video_details.dart';
import '../../../Repository/repository.dart';
import 'episode_item.dart';

class NonSeasonList extends StatefulWidget {
  const NonSeasonList(
      {super.key, required this.setVideo, required this.showLoginPrompt});

  final Function(VideoDetails item) setVideo;
  final Function showLoginPrompt;

  @override
  State<NonSeasonList> createState() => _NonSeasonListState();
}

class _NonSeasonListState extends State<NonSeasonList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
        ),
        // color: Colors.red,
        width: double.infinity,
        height: 24.h,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = data.videoDetails?.videos[index];
            return GestureDetector(
              onTap: () {
                debugPrint("Logged: ${Storage.instance.isLoggedIn}");

                if (Storage.instance.isLoggedIn!) {
                  if (data.videoDetails?.view_permission ?? false) {
                    widget.setVideo(item);
                    debugPrint("Video Clicked${item.title}");
                  } else {
                    CommonFunctions().showNotSubscribedDialog(context);
                  }
                } else {
                  widget.showLoginPrompt(context);
                }
              },
              child: EpisodeItem(
                item: item!,
                currentVideoId: data.currentVideoId!,
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 5.w,
            );
          },
          itemCount: data.videoDetails?.videos.length ?? 0,
        ),
      );
    });
  }
}
