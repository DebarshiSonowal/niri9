// import 'package:appinio_video_player/appinio_video_player.dart';
import 'dart:async';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:lottie/lottie.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../Constants/assets.dart';
import '../../Models/video_details.dart';
import '../../Repository/repository.dart';
import 'Widgets/shimmering_screen_loader.dart';
import 'Widgets/watch_primary_screen.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> with WidgetsBindingObserver {
  Timer? uploadTimer;
  int? lastPlayed;
  VideoPlayerController? videoPlayerController;
  CustomVideoPlayerController? _customVideoPlayerController;
  bool isPlaying = true, showing = false, hasAutoEventTriggered = false;
  Future<bool>? _future;
  Timer? _timer;
  int lastUpdateDuration = 0,
      selectedVideoListId = 0,
      lastUpdateTime = 0,
      selected = 0;
  Map<String, VideoPlayerController>? additionalVideoSources;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("didChangeAppLifecycleState ${state.name}");
    switch (state) {
      case (AppLifecycleState.resumed):
        break;
      case (AppLifecycleState.paused):
        // updateUploadStatus(
        //   _customVideoPlayerController!,
        //   Provider.of<Repository>(context, listen: false).videoDetails!,
        //   "pause",
        //   currentDuration,
        // );
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 0), () {
      // initiateVideoPlayer(context);
      fetchDetails(widget.id);
    });
  }

  @override
  void dispose() {
    KeepScreenOn.turnOff();
    try {
      videoPlayerController?.pause();
      videoPlayerController?.dispose();
      _customVideoPlayerController?.dispose();
    } catch (e) {
      debugPrint("$e");
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          await videoPlayerController?.pause();
          await videoPlayerController?.dispose();
          _customVideoPlayerController?.dispose();
          EasyLoading.dismiss();
        } catch (e) {
          debugPrint("$e");
        }

        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Constants.primaryColor,
            child: FutureBuilder(
              future: _future,
              builder: (context, _) {
                if (_.hasData) {
                  return WatchPrimaryScreen(
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
                    setVideo: (VideoDetails item) async {
                      debugPrint("Showing ${item.videoPlayer}");
                      await initializeVideoPlayer(context, item.videoPlayer);
                      Provider.of<Repository>(context, listen: false).setVideo(item.id ?? 0);
                      selectedVideoListId = item.id ?? 0;
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    setVideoSource:
                        (MapEntry<String, VideoPlayerController> item) {
                      setVideoPlayer(context, item.value);
                    },
                    updateVideoListId: (int item) {
                      setState(() {
                        selectedVideoListId = item;
                      });
                    },
                    id: Provider.of<Repository>(context, listen: false)
                            .videoDetails
                            ?.series_id ??
                        0,
                    fetchFromId: (int item) {
                      fetchDetails(item);
                    },
                  );
                }
                if (_.hasError || (_.hasData && _.data == false)) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(Assets.notFoundAnimation),
                      const Text("This Movie/WebSeries is not available"),
                      SizedBox(
                        height: 2.h,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigation.instance.goBack();
                        },
                        child: Text(
                          "Go Back",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  );
                }
                return const ShimmeringWatchScreenLoader();
              },
            ),
          ),
        ),
      ),
    );
  }

  void fetchDetails(int id) async {
    await fetchVideo(id);
    await fetchRentDetails(id);
  }

  Future<void> fetchRentDetails(int id) async {
    final response = await ApiProvider.instance.getRentPlans(id);
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setRentPlanDetails(response.result);
    } else {}
  }

  Future<bool> fetchVideo(int index) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getVideoDetails(index);
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setVideoDetails(response.video!);

      // await fetchEpisodes(response.video?.series_id ?? 0);
      setState(() {});
      startConditionChecking();

      return true;
    } else {
      // Navigation.instance.goBack();
      return false;
    }
  }

  Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
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
        await getId() ?? "",
        currentDuration,
        "phone",
        // "mobile",
        event_name);
    if (response.success ?? false) {
    } else {}
  }

  Future<bool> reinitializeVideoPlayer(context, url) async {

    final repo = Provider.of<Repository>(context, listen: false);
    final videoDetails = repo.videoDetails;
    final recentViewedList = videoDetails?.recentViewedList;
    debugPrint("Initializing video player $url");
    final response = await ApiProvider.instance.download2(url);
    if (response.success ?? false) {
      additionalVideoSources = {};
      for (var i in response.videoResolutions) {
        additionalVideoSources?.addAll({
          "${i.resolution}": VideoPlayerController.networkUrl(
              Uri.parse(url ?? Assets.videoUrl))
            ..addListener(() => videoControllerListener(context)),
        });
      }
      // additionalVideoSources?.addAll({
      //   "2048": videoPlayerController,
      // });
      setState(() {
        debugPrint("E123B $additionalVideoSources");
      });
    } else {
      debugPrint("E123C ");
      return false;
    }
    try {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(url ?? Assets.videoUrl))
            ..initialize().then((value) async {
              videoPlayerController
                  ?.addListener(() => videoControllerListener(context));
              _customVideoPlayerController = CustomVideoPlayerController(
                context: context,
                videoPlayerController: videoPlayerController!,
                customVideoPlayerSettings: const CustomVideoPlayerSettings(
                  playOnlyOnce: false,

                  // customVideoPlayerPopupSettings: ,
                ),
                additionalVideoSources: additionalVideoSources,
              );
              videoPlayerController?.play().then((value){
                if (recentViewedList?.viewedTime!=null&&selectedVideoListId==recentViewedList?.videoListId) {
                  debugPrint("#condition last ${recentViewedList?.viewedTime}");
                  // _customVideoPlayerController.videoPlayerController.notifyListeners(
                  setState(() {
                    _customVideoPlayerController?.videoPlayerController.seekTo(
                      Duration(
                        seconds: recentViewedList!.viewedTime!,
                      ),
                    );
                  });
                  EasyLoading.dismiss();
                  Future.delayed(const Duration(seconds: 4),(){

                  });
                }
              });
            });
      additionalVideoSources?.addAll({
        "Auto": videoPlayerController!,
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    // EasyLoading.dismiss();
    // if (recentViewedList?.viewedTime!=null&&selectedVideoListId==recentViewedList?.videoListId) {
    //   debugPrint("#condition last ${recentViewedList?.viewedTime}");
    //   // _customVideoPlayerController.videoPlayerController.notifyListeners(
    //   Future.delayed(const Duration(seconds: 4),(){
    //     setState(() {
    //       _customVideoPlayerController?.videoPlayerController.seekTo(
    //         Duration(
    //           seconds: recentViewedList!.viewedTime!,
    //         ),
    //       );
    //     });
    //   });
    // }
    return true;
  }


  Future<bool> initializeVideoPlayer(context, url) async {
    EasyLoading.show(status: 'loading...');
    final repo = Provider.of<Repository>(context, listen: false);
    final videoDetails = repo.videoDetails;
    final recentViewedList = videoDetails?.recentViewedList;
    debugPrint("Initializing video player $url");
    final response = await ApiProvider.instance.download2(url);
    if (response.success ?? false) {
      additionalVideoSources = {};
      for (var i in response.videoResolutions) {
        additionalVideoSources?.addAll({
          "${i.resolution}": VideoPlayerController.networkUrl(
              Uri.parse(url ?? Assets.videoUrl))
            ..addListener(() => videoControllerListener(context)),
        });
      }
      // additionalVideoSources?.addAll({
      //   "2048": videoPlayerController,
      // });
      setState(() {
        debugPrint("E123B $additionalVideoSources");
      });
    } else {
      debugPrint("E123C ");
      return false;
    }
    try {
      videoPlayerController =
      VideoPlayerController.networkUrl(Uri.parse(url ?? Assets.videoUrl))
        ..initialize().then((value) async {
          videoPlayerController
              ?.addListener(() => videoControllerListener(context));
          _customVideoPlayerController = CustomVideoPlayerController(
            context: context,
            videoPlayerController: videoPlayerController!,
            customVideoPlayerSettings: const CustomVideoPlayerSettings(
              playOnlyOnce: false,

              // customVideoPlayerPopupSettings: ,
            ),
            additionalVideoSources: additionalVideoSources,
          );
          videoPlayerController?.play().then((value){
            if (recentViewedList?.viewedTime!=null&&selectedVideoListId==recentViewedList?.videoListId) {
              debugPrint("#condition last ${recentViewedList?.viewedTime}");
              // _customVideoPlayerController.videoPlayerController.notifyListeners(
              setState(() {
                _customVideoPlayerController?.videoPlayerController.seekTo(
                  Duration(
                    seconds: recentViewedList!.viewedTime!,
                  ),
                );
              });
              EasyLoading.dismiss();
              Future.delayed(const Duration(seconds: 4),(){

              });
            }else{
              EasyLoading.dismiss();
            }
          });
        });
      additionalVideoSources?.addAll({
        "Auto": videoPlayerController!,
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }


    return true;
  }

  void startConditionChecking() {
    final repo = Provider.of<Repository>(context, listen: false);
    final videoDetails = repo.videoDetails;

    if (videoDetails?.view_permission ?? false) {
      debugPrint("#condition ${videoDetails?.title} has permission");
      final recentViewedList = videoDetails?.recentViewedList;
      final videoListId = recentViewedList?.videoListId ?? 0;

      if (recentViewedList != null && videoListId != 0) {
        debugPrint(
            "#condition ${videoDetails?.title} have a recently viewed video $videoListId and $recentViewedList \n ${recentViewedList.videoPlayer}");
        repo.setVideo(videoListId);
        final url = recentViewedList.videoPlayer;

        setState(() {
          selectedVideoListId = recentViewedList.videoListId ?? 0;
          if (videoDetails?.season_list?.isNotEmpty ?? false) {
            for (var i = 0; i < (videoDetails?.season_list.length ?? 0); i++) {
              if (videoDetails?.season_list[i].id == videoListId) {
                selected = i;
                debugPrint(
                    "#condition ${videoDetails?.title} selected from season $selected");
                break;
              }
            }
          } else {
            for (var i = 0; i < (videoDetails?.videos.length ?? 0); i++) {
              if (videoDetails?.videos[i].id == videoListId) {
                selected = i;
                debugPrint(
                    "#condition ${videoDetails?.title} selected $selected");
                break;
              }
            }
          }
        });
        _future = reinitializeVideoPlayer(context, url);

      } else {
        debugPrint(
            "#condition ${videoDetails?.title} have first video ${videoDetails?.videos.first.id}");
        _future = reinitializeVideoPlayer(
            context, videoDetails?.videos.first.videoPlayer);

        setState(() {
          selectedVideoListId = videoDetails?.videos.first.id ?? 0;
        });
      }
    } else {
      debugPrint("#condition ${videoDetails?.title} doesn't have permission");
      if (videoDetails?.trailer_player != "") {
        debugPrint("#condition ${videoDetails?.title} have trailer");
        _future = reinitializeVideoPlayer(context, videoDetails?.trailer_player);
      } else {
        debugPrint("#condition ${videoDetails?.title} doesn't have permission");
        _future = false as Future<bool>?;
      }
    }
  }

  void setVideoPlayer(BuildContext context, VideoPlayerController value) async {
    videoPlayerController?.pause();

    _customVideoPlayerController;
    final response = await ApiProvider.instance.download2(value.dataSource);

    if (response.success ?? false) {
      additionalVideoSources = {};

      for (var i in response.videoResolutions) {
        final dataSource =
            "https://customer-edsfz57k0gqg8bse.cloudflarestream.com/eb471d0611714d8133bc092c14ecc979/manifest/${i.url.split("?")[0]}";

        if (value.dataSource != i.url && value.dataSource != dataSource) {
          additionalVideoSources?.addAll({
            "${i.resolution}":
                VideoPlayerController.networkUrl(Uri.parse(dataSource)),
          });
        }
      }

      setState(() {});
    }

    try {
      videoPlayerController = value;
      additionalVideoSources?.addAll({"Auto": videoPlayerController!});

      videoPlayerController
          ?.addListener(() => videoControllerListener(context));

      await videoPlayerController?.initialize();

      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController!,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
          playOnlyOnce: false,
        ),
        additionalVideoSources: additionalVideoSources,
      );

      videoPlayerController?.play();
    } catch (e) {
      debugPrint("Value is ${value.dataSource} ${e}");
    }
  }

  void videoControllerListener(BuildContext context) {
    final int currentDuration = videoPlayerController!.value.position.inSeconds;

    final int forwardTimeInSeconds = int.parse(
      Provider.of<Repository>(context, listen: false)
              .videoSetting
              ?.forwardTime ??
          "10",
    );
    debugPrint("forwardTime $forwardTimeInSeconds");

    if (currentDuration % forwardTimeInSeconds == 0 && !hasAutoEventTriggered) {
      debugPrint("Auto event triggered at $currentDuration seconds.");
      updateUploadStatus(
        _customVideoPlayerController!,
        Provider.of<Repository>(context, listen: false).videoDetails!,
        "auto",
        currentDuration,
      );

      hasAutoEventTriggered = true;
    } else if (currentDuration % forwardTimeInSeconds != 0) {
      // Reset the flag when not at the exact multiple of forwardTimeInSeconds
      hasAutoEventTriggered = false;
    }

    final bool isVideoPlaying = videoPlayerController?.value.isPlaying ?? false;

    if (isVideoPlaying != isPlaying) {
      final String action = isVideoPlaying ? "play" : "pause";
      // Wakelock.toggle(enable: isVideoPlaying);
      if (isVideoPlaying) {
        KeepScreenOn.turnOn();
      } else {
// Reset
        KeepScreenOn.turnOff();
      }

      // Trigger "play" or "pause" event when user manually plays or pauses the video
      updateUploadStatus(
        _customVideoPlayerController!,
        Provider.of<Repository>(context, listen: false).videoDetails!,
        action,
        currentDuration,
      );

      hasAutoEventTriggered =
          false; // Reset the flag when the user manually interacts
      isPlaying = isVideoPlaying;
    }

    setState(() {});
  }
}
