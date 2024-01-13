import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:niri9/Functions/HomeScreen/Widgets/ott_item.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/video_section.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/video.dart';
import '../../../Models/video_details.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import '../../HomeScreen/Widgets/dynamic_list_item.dart';
import 'alternative_options_bar.dart';
import 'description_section.dart';
import 'episodes_slider.dart';
import 'info_bar.dart';
import 'more_like_this_section.dart';
import 'options_bar.dart';

class WatchPrimaryScreen extends StatelessWidget {
  const WatchPrimaryScreen({
    super.key,
    required CustomVideoPlayerController? customVideoPlayerController,
    required this.videoPlayerController,
    required this.showing,
    required this.onClicked,
    required this.setVideo,
    required this.setVideoSource,
    required this.updateVideoListId,
    required this.id, required this.fetchFromId,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CustomVideoPlayerController? _customVideoPlayerController;
  final VideoPlayerController? videoPlayerController;
  final bool showing;
  final int id;
  final Function onClicked;
  final Function(VideoDetails item) setVideo;
  final Function(int item) updateVideoListId;
  final Function(int item) fetchFromId;
  final Function(MapEntry<String, VideoPlayerController> item) setVideoSource;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 100.h,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
              ),
              color: Colors.black,
              // padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await videoPlayerController?.pause();
                      await videoPlayerController?.dispose();
                      _customVideoPlayerController?.dispose();
                      Navigation.instance.goBack();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 15.sp,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     showQuality(context);
                  //   },
                  //   child: const Icon(
                  //     Icons.settings,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
            (_customVideoPlayerController != null &&
                    videoPlayerController != null)
                ? VideoSection(
                    customVideoPlayerController: _customVideoPlayerController!,
                    isPlaying: videoPlayerController!.value.isPlaying,
                    showing: showing,
                    onClicked: onClicked,
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.black,
                    highlightColor: Colors.grey.shade800,
                    child: Container(
                      height: 30.h,
                      color: Colors.black,
                    ),
                  ),
            const InfoBar(),
            (_customVideoPlayerController != null &&
                    videoPlayerController != null)
                ? OptionsBar(
                    customVideoPlayerController: _customVideoPlayerController!,
                  )
                : const AlternativeOptionsBar(),
            const DescriptionSection(),
            EpisodeSlider(
              setVideo: (VideoDetails item) => setVideo(item),
              updateVideoListId: (int value) {
                updateVideoListId(value);
              },
              id: id,
              fetchFromId: (int value) {
                fetchFromId(value);
              },
              // selected: selected,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 3.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5.w,
                    color: Colors.yellow,
                    child: Center(
                      child: Text(
                        "Ad",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Image.asset(
                    Assets.advertiseBannerImage,
                    height: 12.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            MoreLikeThisSection(
              data:
                  Provider.of<Repository>(context, listen: false).videoDetails!,
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }
}
