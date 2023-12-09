// import 'package:appinio_video_player/appinio_video_player.dart';
import 'dart:async';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/video.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// import 'package:read_more_text/read_more_text.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Models/video_details.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import 'Widgets/description_section.dart';
import 'Widgets/episodes_slider.dart';
import 'Widgets/icon_text_button.dart';
import 'Widgets/info_bar.dart';
import 'Widgets/options_bar.dart';
import 'Widgets/video_section.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  Timer? uploadTimer;
  int? lastPlayed;
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  var list = [
    "Season 1",
    "Season 2",
  ];
  var season1 = [
    Assets.episodeImage,
    Assets.episodeImage2,
    Assets.episodeImage,
    Assets.episodeImage2,
  ];
  var season2 = [
    Assets.episodeImage2,
    Assets.episodeImage,
    Assets.episodeImage2,
    Assets.episodeImage,
  ];
  bool isPlaying = true, showing = false;
  int selected = 0;
  Future<bool>? _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () {
      // initiateVideoPlayer(context);
      fetchDetails(widget.index);
    });
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Constants.primaryColor,
          child: FutureBuilder(
            future: _future,
            builder: (context, _) {
              return _.hasData
                  ? WatchPrimaryScreen(
                      customVideoPlayerController: _customVideoPlayerController,
                      videoPlayerController: videoPlayerController,
                      showing: showing,
                      onClicked: () {
                        setState(() {
                          showing = true;
                        });
                        if (_timer?.isActive ?? false) _timer?.cancel();
                        _timer = Timer(const Duration(seconds: 5), () {
                          setState(() {
                            showing = false;
                          });
                        });
                      },
                      setVideo: (VideoDetails item) {
                        initiateVideoPlayer(context, item.videoPlayer);
                        Provider.of<Repository>(context, listen: false)
                            .setVideo(item.id ?? 0);
                      },
                    )
                  : const ShimmeringWatchScreenLoader();
            },
          ),
        ),
      ),
    );
  }

  void fetchDetails(int index) async {
    await fetchVideo(index);
  }

  Future<bool> fetchVideo(int index) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getVideoDetails(index);
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setVideoDetails(response.video!);

      await fetchEpisodes(response.video?.series_id ?? 0);
      setState(() {});
      if (Storage.instance.isLoggedIn) {
        _future = initiateVideoPlayer(
            context,
            Provider.of<Repository>(context, listen: false)
                .videoDetails
                ?.videos
                .first
                .videoPlayer);
      } else {
        _future = initiateVideoPlayer(context, Assets.videoUrl);
      }

      return true;
    } else {
      // Navigation.instance.goBack();
      return false;
    }
  }

  void updateUploadStatus(
      CustomVideoPlayerController _customVideoPlayerController,
      Video video,
      String event_name,
      int currentDuration) async {
    final response = await ApiProvider.instance.updateVideoTime(video.id,
        video.readable_time, "", currentDuration, "mobile", event_name);
    if (response.success ?? false) {
    } else {}
  }

  Future<bool> initiateVideoPlayer(context, url) async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(url ?? Assets.videoUrl));
    debugPrint(
        "Initializing video player ${Provider.of<Repository>(context, listen: false).videoDetails?.videos.first.videoPlayer}");
    await videoPlayerController.initialize();

    videoPlayerController.addListener(() {
      debugPrint("listener is triggered video player");
      int currentDuration = videoPlayerController.value.position.inMilliseconds;

      if (currentDuration >= 10000 && uploadTimer == null) {
        // Start a Timer after 10 seconds to call updateUploadStatus once
        uploadTimer = Timer(const Duration(seconds: 10), () {
          if (videoPlayerController.value.isPlaying) {
            // Call updateUploadStatus when the video is playing
            updateUploadStatus(
              _customVideoPlayerController,
              Provider.of<Repository>(context, listen: false).videoDetails!,
              "play",
              currentDuration,
            );
          }
          uploadTimer?.cancel(); // Cancel the Timer
          uploadTimer = null; // Reset the Timer
        });
      }

      // Check if the video is currently playing
      if (videoPlayerController.value.isPlaying) {
        if (!isPlaying) {
          // Call updateUploadStatus when video starts playing
          updateUploadStatus(
            _customVideoPlayerController,
            Provider.of<Repository>(context, listen: false).videoDetails!,
            "play",
            currentDuration,
          );
          isPlaying = true;
        }
      } else {
        isPlaying = false;
      }

      setState(() {});
    });

    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
          playOnlyOnce: true,
          // customVideoPlayerPopupSettings: ,
        ));
    videoPlayerController.play();
    return true;
  }

  fetchEpisodes(int id) async {
    final response = await ApiProvider.instance.getEpisodes(id);
    if (response.success ?? false) {
      debugPrint("MyEpisodes ${response.result}");
      for (var i in response.result!) {
        debugPrint("Episodes Adding ${i.video_list.length}");
        Provider.of<Repository>(context, listen: false)
            .addSeasons(i.video_list ?? []);
      }
      Provider.of<Repository>(context, listen: false)
          .setVideo(response.result[0].id ?? 0);
      return true;
    } else {
      return false;
    }
  }
}

class ShimmeringWatchScreenLoader extends StatelessWidget {
  const ShimmeringWatchScreenLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.grey.shade800,
            child: Container(
              height: 20.h,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5.w,
              vertical: 2.h,
            ),
            height: 10.h,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white30,
                  child: Container(
                    height: 2.h,
                    width: 30.w,
                    color: Colors.white30,
                  ),
                ),
                SizedBox(
                  height: 12.sp,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white30,
                  child: Container(
                    height: 2.h,
                    width: 50.w,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.white30,
            thickness: 0.1.h,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          Container(
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
          SizedBox(
            height: 1.5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5.w,
              vertical: 1.h,
            ),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white30,
                  child: Container(
                    height: 1.5.h,
                    width: 15.w,
                    color: Colors.white30,
                  ),
                ),
                SizedBox(
                  width: 4.w,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white30,
                  child: Container(
                    height: 1.5.h,
                    width: 15.w,
                    color: Colors.white30,
                  ),
                ),
                const Spacer(),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white30,
                  child: Container(
                    height: 1.5.h,
                    width: 15.w,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.white30,
            child: Container(
              height: 5.h,
              width: 90.w,
              color: Colors.white30,
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.white30,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white30,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 2.h,
          ),
          Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.white30,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8.w,
              ),
              height: 13.h,
              width: 90.w,
              color: Colors.white30,
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          // SizedBox(
          //   height: 20.h,
          //   width: double.infinity,
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     itemBuilder: (context, index) {
          //       return Container(
          //         color: Colors.black,
          //         width: 10.w,
          //         height: 20.h,
          //       );
          //     },
          //     itemCount: 4,
          //   ),
          // ),
        ],
      ),
    );
  }
}

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
            const OptionsBar(),
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
