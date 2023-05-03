import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EpisodesSlider extends StatelessWidget {
  const EpisodesSlider({
    super.key,
    required this.selected,
    required this.season1,
    required this.season2,
  });

  final int selected;
  final List<String> season1;
  final List<String> season2;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            var item = (selected == 0 ? season1 : season2)[index];
            return Image.asset(
              item,
              fit: BoxFit.fill,
              // height: 10.h,
              width: 40.w,
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 5.w,
            );
          },
          itemCount: (selected == 0 ? season1 : season2).length),
    );
  }
}