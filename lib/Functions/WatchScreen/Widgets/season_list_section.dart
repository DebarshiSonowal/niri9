import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/video.dart';
import '../../../Models/video_details.dart';
import '../../../Repository/repository.dart';
import 'episode_item.dart';
import 'rent_bottom_sheet.dart';

class SeasonListSection extends StatelessWidget {
  const SeasonListSection({super.key, required this.selected, required this.setVideo, required this.showLoginPrompt});
  // final Repository data;
  final int selected;
  final Function(VideoDetails item) setVideo;
  final Function showLoginPrompt;
  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(
      builder: (context,data,_) {
        return (data.currentSeasons.isEmpty||data.currentSeasons[selected]
            .video_list.isEmpty)?Container():Container(
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
                  final isLoggedIn = Storage.instance.isLoggedIn ?? false;
                  final hasSubscription = data.user?.has_subscription ?? false;
                  final hasRent = data.videoDetails?.has_rent ?? false;
                  final hasActiveRent =
                      hasRent && (data.videoDetails?.has_plan ?? false);

                  debugPrint("Logged: $isLoggedIn");
                  debugPrint(
                      "Video Clicked${item.title} \n ${item.profile_pic} \n ${item.profilePicFile}");

                  if (!isLoggedIn) {
                    showLoginPrompt(context);
                    return;
                  }

                  if (hasSubscription || hasActiveRent) {
                    setVideo(item);
                    return;
                  }

                  if (hasRent) {
                    _showRentBottomSheet(context, data.videoDetails);
                    return;
                  }

                  CommonFunctions().showNotSubscribedDialog(context);
                },
                // child: Text("${data.currentSeasons[selected]}"),
                child: EpisodeItem(
                  item: item,
                  currentVideoId: data.currentVideoId??0,
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
    );
  }

  Future<void> _showRentBottomSheet(
      BuildContext context, Video? videoDetails) async {
    if (videoDetails == null) {
      CommonFunctions().showNotSubscribedDialog(context);
      return;
    }
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RentBottomSheet(videoDetails: videoDetails),
    );
  }
}
