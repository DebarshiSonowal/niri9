import 'package:flutter/material.dart';
import 'package:niri9/Models/season.dart';
import 'package:sizer/sizer.dart';

class SeasonsItem extends StatelessWidget {
  const SeasonsItem({
    super.key,
    required this.selected,
    required this.list,
    required this.onTap,
    required this.index,
  });

  final int index;
  final Function onTap;
  final int selected;
  final List<Season> list;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 1.h,
            horizontal: 2.w,
          ),
          decoration: BoxDecoration(
            color: selected == index ? Colors.white : const Color(0xff7c7c7c),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            list[index].title??"",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black,
              fontSize: 11.sp,
            ),
          ),
        ),
      ),
    );
  }
}
