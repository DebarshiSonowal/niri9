import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:niri9/Constants/common_functions.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/LanguageSelectedPage/language_selected_page.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/seasons_itme.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/seasons_list.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/assets.dart';
import '../../../Repository/repository.dart';
import 'episode_item.dart';
import 'non_season_list.dart';
import 'rent_bottom_sheet.dart';
import 'season_list_section.dart';

class EpisodeSlider extends StatefulWidget {
  const EpisodeSlider(
      {super.key,
      required this.setVideo,
      required this.updateVideoListId,
      required this.id,
      required this.fetchFromId});

  final int id;
  final Function(VideoDetails item) setVideo;
  final Function(int value) updateVideoListId;
  final Function(int value) fetchFromId;

  @override
  State<EpisodeSlider> createState() => _EpisodeSliderState();
}

class _EpisodeSliderState extends State<EpisodeSlider> {
  int selected = 0;
  Future<bool>? _future;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _future = fetchEpisodes(widget.id, context, (int val) {
        widget.updateVideoListId(val);
      });
    });
  } // final List<String> season1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, _) {
          if (_.hasData && _.data != null && _.data != false) {
            return Consumer<Repository>(builder: (context, data, _) {
              return (data.videoDetails?.video_type_id == 2 &&
                      (data.currentSeasons ?? []).isNotEmpty)
                  ? Column(
                      children: [
                        (data.videoDetails?.season_list ?? []).isNotEmpty
                            ? SeasonsList(
                                data: data,
                                selected: selected,
                                updateSelected: (int value) {
                                  setState(() {
                                    selected = value;
                                  });
                                  widget.fetchFromId(
                                      data.currentSeasons[selected].id ?? 0);
                                },
                              )
                            : data.currentSeasons.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    child: Row(
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
                                      ],
                                    ),
                                  )
                                : Container(),
                        (data.videoDetails?.season_list ?? []).isNotEmpty
                            ? SeasonListSection(
                                // data: data,
                                setVideo: (VideoDetails item) {
                                  widget.setVideo(item);
                                },
                                showLoginPrompt: () => showLoginPrompt(context),
                                selected: selected,
                              )
                            : NonSeasonList(
                                // data: data,
                                setVideo: (VideoDetails item) {
                                  widget.setVideo(item);
                                },
                                showLoginPrompt: () => showLoginPrompt(context),
                              ),
                      ],
                    )
                  : Container();
            });
          }
          if (_.hasError || _.data == null || _.data == false) {
            return Container();
          }
          return const ShimmerLanguageScreen();
        });
  }

  void showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Oops!",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
          ),
          content: Text(
            "Looks like you haven't logged in",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigation.instance.navigate(Routes.loginScreen);
              },
              child: Text(
                "Login",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> fetchEpisodes(
    int id, BuildContext context, Function updateListId) async {
  final response = await ApiProvider.instance.getEpisodes(id);
  if (response.success ?? false) {
    debugPrint("MyEpisodes ${response.result}");
    // for (var i in response.result) {
    //   debugPrint("Episodes Adding ${i.id}\n${i.title}\n${i.video_list.length}");
    //   Provider.of<Repository>(context, listen: false)
    //       .addSeasons(i.video_list ?? []);
    // }
    Provider.of<Repository>(context, listen: false).setSeasons(response.result);
    debugPrint(
        "Watchloading: \n${response.result[0].id}\n${response.result[0].video_list.first.id}");
    // Provider.of<Repository>(context, listen: false)
    //     .setVideo(response.result[0].id ?? 0);
    // updateListId(response.result[0].video_list.first.id ?? 0);
    return true;
  } else {
    return false;
  }
}
