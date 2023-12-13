import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/video_section.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Models/video_details.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../HomeScreen/Widgets/dynamic_list_item.dart';
import 'description_section.dart';
import 'episodes_slider.dart';
import 'info_bar.dart';
import 'options_bar.dart';

class WatchPrimaryScreen extends StatelessWidget {
  const WatchPrimaryScreen({
    super.key,
    required CustomVideoPlayerController customVideoPlayerController,
    required this.videoPlayerController,
    required this.showing,
    required this.onClicked,
    required this.setVideo,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CustomVideoPlayerController _customVideoPlayerController;
  final VideoPlayerController videoPlayerController;
  final bool showing;
  final Function onClicked;
  final Function(VideoDetails item) setVideo;

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
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigation.instance.goBack();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            VideoSection(
              customVideoPlayerController: _customVideoPlayerController,
              isPlaying: videoPlayerController.value.isPlaying,
              showing: showing,
              onClicked: onClicked,
            ),
            const InfoBar(),
            OptionsBar(
              customVideoPlayerController: _customVideoPlayerController,
            ),
            const DescriptionSection(),
            EpisodeSlider(
              setVideo: (VideoDetails item) => setVideo(item),
              // selected: selected,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 3.h,
              ),
              child: Image.asset(
                Assets.advertiseBannerImage,
                height: 12.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Consumer<Repository>(builder: (context, data, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var item = data.homeSections[index];
                  return item.videos.isNotEmpty
                      ? DynamicListItem(
                    text: item.title ?? "",
                    list: item.videos ?? [],
                    onTap: () {
                      Navigation.instance
                          .navigate(Routes.moreScreen, args: 0);
                    },
                  )
                      : Container();
                },
                itemCount: data.homeSections.length,
              );
            }),
          ],
        ),
      ),
    );
  }
}