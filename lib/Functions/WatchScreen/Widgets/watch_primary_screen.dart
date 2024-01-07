import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/video_section.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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
    required CustomVideoPlayerController? customVideoPlayerController,
    required this.videoPlayerController,
    required this.showing,
    required this.onClicked,
    required this.setVideo,
    required this.setVideoSource,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CustomVideoPlayerController? _customVideoPlayerController;
  final VideoPlayerController? videoPlayerController;
  final bool showing;
  final Function onClicked;
  final Function(VideoDetails item) setVideo;
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
                videoPlayerController != null)?VideoSection(
              customVideoPlayerController: _customVideoPlayerController!,
              isPlaying: videoPlayerController!.value.isPlaying,
              showing: showing,
              onClicked: onClicked,
            ):Shimmer.fromColors(
              baseColor: Colors.black,
              highlightColor: Colors.grey.shade800,
              child: Container(
                height: 30.h,
                color: Colors.black,
              ),
            ),
            const InfoBar(),
            (_customVideoPlayerController != null &&
                videoPlayerController != null)?OptionsBar(
              customVideoPlayerController: _customVideoPlayerController!,
            ): Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white54,
                    width: 0.03.h,
                  ),
                  bottom: BorderSide(
                    color: Colors.white54,
                    width: 0.03.h,
                  ),
                ),
              ),
              height: 10.h,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      color: const Color(0xff2a2829),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Icon(
                                  Icons.share,
                                  color: Colors.white30,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(
                                height: 1.2.h,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Container(
                                  height: 2.h,
                                  width: 10.w,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Icon(
                                  Icons.playlist_add,
                                  color: Colors.white30,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(
                                height: 1.2.h,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Container(
                                  height: 2.h,
                                  width: 10.w,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Icon(
                                  Icons.money,
                                  color: Colors.white30,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(
                                height: 1.2.h,
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white30,
                                child: Container(
                                  height: 2.h,
                                  width: 10.w,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white30,
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white30,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(
                            height: 1.2.h,
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white30,
                            child: Container(
                              height: 2.h,
                              width: 20.w,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
