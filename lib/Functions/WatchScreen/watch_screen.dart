// import 'package:appinio_video_player/appinio_video_player.dart';
import 'dart:async';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'Widgets/shimmering_screen_loader.dart';
import 'Widgets/video_section.dart';
import 'Widgets/watch_primary_screen.dart';

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
  int lastUpdateDuration = 0;
  int selectedVideoListId = 0;

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
                        showing = true;
                        if (mounted) {
                          setState(() {});
                        }
                        if (_timer?.isActive ?? false) _timer?.cancel();
                        _timer = Timer(const Duration(seconds: 3), () {
                          showing = false;
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      setVideo: (VideoDetails item) {
                        initializeVideoPlayer(context, item.videoPlayer);
                        Provider.of<Repository>(context, listen: false)
                            .setVideo(item.id ?? 0);
                        selectedVideoListId = item.id ?? 0;
                        if (mounted) {
                          setState(() {});
                        }
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
      startConditionChecking();

      return true;
    } else {
      // Navigation.instance.goBack();
      return false;
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  void updateUploadStatus(
      CustomVideoPlayerController _customVideoPlayerController,
      Video video,
      String event_name,
      int currentDuration) async {
    final response = await ApiProvider.instance.updateVideoTime(
        // video.id,
        selectedVideoListId,
        currentDuration,
        // video.readable_time,
        await _getId() ?? "",
        currentDuration,
        "phone",
        // "mobile",
        event_name);
    if (response.success ?? false) {
    } else {}
  }

  Future<bool> initializeVideoPlayer(context, url) async {
    try {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(url ?? Assets.videoUrl));
      await videoPlayerController.initialize();

      videoPlayerController.addListener(() {
        debugPrint("listener is triggered video player");
        int currentDuration =
            videoPlayerController.value.position.inMilliseconds;

        if (currentDuration >=
                (int.parse(Provider.of<Repository>(context, listen: false)
                            .videoSetting
                            ?.forwardTime ??
                        "10") *
                    1000) &&
            uploadTimer == null) {
          debugPrint("upload timer $currentDuration");
          // Start a Timer after 10 seconds to call updateUploadStatus once
          uploadTimer = Timer(
              Duration(
                  seconds: int.parse(
                      Provider.of<Repository>(context, listen: false)
                              .videoSetting
                              ?.forwardTime ??
                          "10")), () {
            if (videoPlayerController.value.isPlaying) {
              // Call updateUploadStatus when the video is playing
              updateUploadStatus(
                _customVideoPlayerController,
                Provider.of<Repository>(context, listen: false).videoDetails!,
                "auto",
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
    } catch (e) {
      print(e);
      return false;
    }
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
      setState(() {
        selectedVideoListId = response.result[0].video_list.first.id??0;
      });
      return true;
    } else {
      return false;
    }
  }

  void startConditionChecking() {
    if (Storage.instance.isLoggedIn &&
        (Provider.of<Repository>(context, listen: false)
                .videoDetails
                ?.view_permission ??
            false)) {
      if (Provider.of<Repository>(context, listen: false)
                  .videoDetails
                  ?.recentViewedList !=
              null &&
          (Provider.of<Repository>(context, listen: false)
                      .videoDetails
                      ?.recentViewedList
                      ?.videoListId ??
                  0) !=
              0) {
        Provider.of<Repository>(context, listen: false).setVideo(
            Provider.of<Repository>(context, listen: false)
                    .videoDetails
                    ?.recentViewedList
                    ?.videoId ??
                0);
        final url = (Provider.of<Repository>(context, listen: false)
                .videoDetails
                ?.videos
                .where((element) =>
                    (Provider.of<Repository>(context, listen: false)
                            .videoDetails
                            ?.recentViewedList
                            ?.videoListId ??
                        0) ==
                    element.id)
                .first
                .videoPlayer) ??
            (Provider.of<Repository>(context, listen: false)
                .videoDetails
                ?.videos
                .first
                .videoPlayer);
        setState(() {

          selectedVideoListId = Provider.of<Repository>(context, listen: false)
              .videoDetails
              ?.recentViewedList
              ?.videoListId ??
              0;
          for (var i = 0;
              i <
                  (Provider.of<Repository>(context, listen: false)
                          .videoDetails
                          ?.season_list
                          .length ??
                      0);
              i++) {
            if (Provider.of<Repository>(context, listen: false)
                    .videoDetails
                    ?.season_list[i]
                    .id ==
                Provider.of<Repository>(context, listen: false)
                    .videoDetails
                    ?.recentViewedList
                    ?.videoListId) {
              selected = i;
              break;
            }
          }
        });
        _future = initializeVideoPlayer(context, url);
        // videoPlayerController.seekTo(Duration());
      } else {
        _future = initializeVideoPlayer(
            context,
            Provider.of<Repository>(context, listen: false)
                .videoDetails
                ?.videos
                .first
                .videoPlayer);
        setState(() {
          selectedVideoListId = Provider.of<Repository>(context, listen: false)
                  .videoDetails
                  ?.videos
                  .first
                  .id ??
              0;
        });
      }
    } else {
      _future = initializeVideoPlayer(
          context,
          Provider.of<Repository>(context, listen: false)
                  .videoDetails
                  ?.trailer_player ??
              Assets.videoUrl);
    }
  }
}
