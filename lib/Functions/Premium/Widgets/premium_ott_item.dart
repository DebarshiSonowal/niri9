import 'package:flutter/material.dart';
import 'package:niri9/Widgets/gradient_text.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';

class PremiumOttItem extends StatelessWidget {
  const PremiumOttItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.index,
  });

  final int index;
  final OTT item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: double.infinity,
            width: 23.w,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.image!,
                // // width: 22.w,
                // width: 20.w,
                // height: 16.h,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: 2.w,
            ),
            child: GradientText(
              "${index + 1}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 22.sp,
                    // fontWeight: FontWeight.bold,
                  ),
              gradient: LinearGradient(colors: []),
            ),
          ),
        ],
      ),
    );
  }
}
