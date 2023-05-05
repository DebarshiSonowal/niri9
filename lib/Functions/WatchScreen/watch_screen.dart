import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:read_more_text/read_more_text.dart';
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
    videoPlayerController = VideoPlayerController.network(Assets.videoUrl)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
    Future.delayed(const Duration(seconds: 2), () {
      videoPlayerController
          .play()
          .onError((error, stackTrace) => debugPrint(error.toString()));
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                VideoSection(
                    customVideoPlayerController: _customVideoPlayerController),
                const InfoBar(),
                const OptionsBar(),
                const DescriptionSection(),
                Container(
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                            list: list,
                            onTap: () {
                              setState(() {
                                selected = index;
                              });
                            },
                          );
                        },
                        itemCount: list.length,
                      ),
                    ],
                  ),
                ),
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
                      var item = data.dynamicList[index];
                      return DynamicListItem(
                        text: item.title ?? "",
                        list: item.list ?? [],
                        onTap: () {

                          Navigation.instance
                              .navigate(Routes.moreScreen, args: 0);
                        },
                      );
                    },
                    itemCount: data.dynamicList.length,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
