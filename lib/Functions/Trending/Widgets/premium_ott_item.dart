import 'dart:ui';

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
            width: 35.w,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                item.image!,
                // // width: 22.w,
                // width: 20.w,
                // height: 16.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
            ),
            margin: EdgeInsets.only(
              right: 2.w,
            ),
            child: Text(
              "${index + 1}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                  ),
              // gradient: const LinearGradient(
              //   colors: [
              //     Color(0xff8230c6),
              //     Colors.black,
              //   ],
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
