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
                final isLoggedIn = Storage.instance.isLoggedIn ?? false;
                final hasSubscription = data.user?.has_subscription ?? false;
                final hasRent = data.videoDetails?.has_rent ?? false;
                final hasActiveRent =
                    hasRent && (data.videoDetails?.has_plan ?? false);

                debugPrint("Logged: $isLoggedIn");

                if (!isLoggedIn) {
                  widget.showLoginPrompt(context);
                  return;
                }

                if (hasSubscription || hasActiveRent) {
                  widget.setVideo(item);
                  debugPrint("Video Clicked${item.title}");
                  return;
                }

                if (hasRent) {
                  _showRentBottomSheet(context, data.videoDetails);
                  return;
                }

                CommonFunctions().showNotSubscribedDialog(context);
              },
              child: EpisodeItem(
                item: item!,
                currentVideoId: data.currentVideoId??0,
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
