import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/seasons_itme.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
                (data.videoDetails?.season_list ?? []).isNotEmpty?Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                  ),
                  // color: Colors.red,
                  width: double.infinity,
                  height: 14.h,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var item = data.currentSeasons[selected][index];
                      return GestureDetector(
                        onTap: () {
                          widget.setVideo(item);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:(item.id == data.currentVideoId)?Constants.thirdColor:Colors.transparent,
                              width: 0.5.w,
                            )
                          ),
                          child: CachedNetworkImage(
                            imageUrl: item.profile_pic ?? "",
                            fit: BoxFit.fill,
                            // height: 10.h,
                            width: 40.w,
                          ),
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
                ):Container(),
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

}
