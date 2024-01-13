import 'package:flutter/material.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/seasons_itme.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:sizer/sizer.dart';

class SeasonsList extends StatelessWidget {
  const SeasonsList({super.key, required this.data, required this.selected, required this.updateSelected});
  final Repository data;
  final int selected;
  final Function(int value) updateSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 2.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
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
          (data.videoDetails?.season_list ?? [])
              .isNotEmpty
              ? SizedBox(
            height: 8.h,
            width: 65.w,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SeasonsItem(
                  index: index,
                  selected: selected,
                  list: data.videoDetails
                      ?.season_list ??
                      [],
                  onTap: () {
                    updateSelected(index);
                    debugPrint(
                        "${data.currentSeasons[selected].title}");
                  },
                );
              },
              itemCount: data.videoDetails
                  ?.season_list.length,
            ),
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}
