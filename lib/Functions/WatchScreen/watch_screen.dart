// import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';

// import 'package:read_more_text/read_more_text.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import 'Widgets/description_section.dart';
import 'Widgets/episodes_slider.dart';
import 'Widgets/icon_text_button.dart';
import 'Widgets/info_bar.dart';
import 'Widgets/options_bar.dart';
import 'Widgets/seasons_itme.dart';
import 'Widgets/video_section.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
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

  int selected = 0;

  @override
  void initState() {
    super.initState();
    // fetchDetails(widget.index);
    // videoPlayerController = VideoPlayerController.network(Assets.videoUrl)
    //   ..initialize().then((value) => setState(() {}));
    // _customVideoPlayerController = CustomVideoPlayerController(
    //   context: context,
    //   videoPlayerController: videoPlayerController,
    // );
    // Future.delayed(const Duration(seconds: 2), () {
    //   videoPlayerController
    //       .play()
    //       .onError((error, stackTrace) => debugPrint(error.toString()));
    // });
    Future.delayed(const Duration(seconds: 0), () {
      fetchDetails(widget.index);
    });
  }

  @override
  void dispose() {
    _customVideoPlayerController?.dispose();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                VideoSection(
                    customVideoPlayerController: _customVideoPlayerController),
                const InfoBar(),
                const OptionsBar(),
                const DescriptionSection(),
                Consumer<Repository>(builder: (context, data, _) {
                  return (data.videoDetails?.season_list ?? []).isNotEmpty
                      ? Container(
                          height: 8.5.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 2.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Episodes",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return SeasonsItem(
                                    index: index,
                                    selected: selected,
                                    list: data.videoDetails?.season_list ?? [],
                                    onTap: () {
                                      setState(() {
                                        selected = index;
                                      });
                                    },
                                  );
                                },
                                itemCount:
                                    data.videoDetails?.season_list.length,
                              ),
                            ],
                          ),
                        )
                      : Container();
                }),
                EpisodesSlider(
                    selected: selected, season1: season1, season2: season2),
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
                      var item = data.sections[index];
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
                    itemCount: data.sections.length,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void fetchDetails(int index) async {
    await fetchVideo(index);
  }

  Future<void> fetchVideo(int index) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getVideoDetails(index);
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setVideoDetails(response.video!);
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
          Provider.of<Repository>(context, listen: false)
                  .videoDetails
                  ?.web_url ??
              Assets.videoUrl))
        ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController!,
      );
      Future.delayed(const Duration(seconds: 2), () {
        videoPlayerController
            ?.play()
            .onError((error, stackTrace) => debugPrint(error.toString()));
        setState(() {});
      });
      return;
    } else {
      Navigation.instance.goBack();
      return;
    }
  }
}
