import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/video_details.dart';
import '../../../Repository/repository.dart';
import 'episode_item.dart';

class SeasonListSection extends StatelessWidget {
  const SeasonListSection({super.key, required this.data, required this.selected, required this.setVideo, required this.showLoginPrompt});
  final Repository data;
  final int selected;
  final Function(VideoDetails item) setVideo;
  final Function showLoginPrompt;
  @override
  Widget build(BuildContext context) {
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
          var item = data.currentSeasons[selected]
              .video_list[index];
          return GestureDetector(
            onTap: () {
              debugPrint(
                  "Logged: ${Storage.instance.isLoggedIn}");
              debugPrint(
                  "Video Clicked${item.title} \n ${item.profile_pic} \n ${item.profilePicFile}");
              if (Storage.instance.isLoggedIn!) {
                if (data.videoDetails
                    ?.view_permission ??
                    false) {
                  setVideo(item);
                } else {
                  CommonFunctions()
                      .showNotSubscribedDialog(
                      context);
                }
              } else {
                showLoginPrompt(context);
              }
            },
            // child: Text("${data.currentSeasons[selected]}"),
            child: EpisodeItem(
              item: item,
              currentVideoId: data.currentVideoId!,
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 5.w,
          );
        },
        itemCount: data.currentSeasons[selected]
            .video_list.length,
      ),
    );
  }
}
