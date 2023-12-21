import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/seasons_itme.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Repository/repository.dart';
import 'rent_bottom_sheet.dart';

class EpisodeSlider extends StatefulWidget {
  const EpisodeSlider({super.key, required this.setVideo});

  final Function(VideoDetails item) setVideo;

  @override
  State<EpisodeSlider> createState() => _EpisodeSliderState();
}

class _EpisodeSliderState extends State<EpisodeSlider> {
  int selected = 0;

  // final List<String> season1;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return (data.currentSeasons ?? []).isNotEmpty
          ? Column(
              children: [
                (data.videoDetails?.season_list ?? []).isNotEmpty
                    ? Container(
                        height: 8.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            SizedBox(
                              height: 8.h,
                              width: 65.w,
                              child: ListView.builder(
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
                            ),
                          ],
                        ),
                      )
                    : Container(),
                (data.videoDetails?.season_list ?? []).isNotEmpty
                    ? Container(
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
                            var item = data.currentSeasons[selected][index];
                            return GestureDetector(
                              onTap: () {
                                debugPrint("Logged: ${Storage.instance.isLoggedIn}");

                                if (Storage.instance.isLoggedIn!) {
                                  widget.setVideo(item);
                                  debugPrint(
                                      "Video Clicked${item.videoPlayer}");
                                } else {
                                  showLoginPrompt(context);
                                }
                              },
                              child: EpisodeItem(
                                item: item,
                                currentVideoId: data.currentVideoId!,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              width: 5.w,
                            );
                          },
                          itemCount: data.currentSeasons[selected].length,
                        ),
                      )
                    : Container(),
              ],
            )
          : Container();
    });
  }

  void showRenting(context) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      // context and builder are
      // required properties in this widget
      context: context,
      builder: (BuildContext context) {
        // we set up a container inside which
        // we create center column and display text

        // Returning SizedBox instead of a Container
        return const RentBottomSheet();
      },
    );
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

class EpisodeItem extends StatelessWidget {
  const EpisodeItem({
    super.key,
    required this.item,
    required this.currentVideoId,
  });

  final VideoDetails item;
  final int currentVideoId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: (item.id == currentVideoId)
            ? Constants.thirdColor
            : Colors.transparent,
        width: 0.5.w,
      )),
      child: CachedNetworkImage(
        imageUrl: item.profile_pic ?? "",
        fit: BoxFit.fill,
        // height: 10.h,
        width: 40.w,
        placeholder: (context, index) {
          return Image.asset(
            Assets.logoTransparent,
          ).animate();
        },
      ),
    );
  }
}
