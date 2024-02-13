import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/film_festival.dart';

class FestivalItem extends StatelessWidget {
  const FestivalItem({
    super.key,
    required this.isCurrent,
    required this.item,
  });

  final bool isCurrent;
  final FilmFestival item;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        alignment: Alignment.center,
        width: 27.w,
        decoration: BoxDecoration(
          // color: Color(0xff868686),
          color: isCurrent ? const Color(0xfffdfefe) : const Color(0xff868686),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        child: Center(
          child: Text(
            "${item.name}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isCurrent ? Colors.black : Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}