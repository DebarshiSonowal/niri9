import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';

class PremiumOttItem2 extends StatelessWidget {
  const PremiumOttItem2({
    super.key,
    required this.item,
    required this.onTap,
  });

  final OTT item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: 38.w,
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
      ),
    );
  }
}