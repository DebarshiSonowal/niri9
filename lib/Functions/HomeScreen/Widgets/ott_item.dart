import 'package:flutter/material.dart';
import 'package:niri9/Models/movies.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';

class OttItem extends StatelessWidget {
  const OttItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Movies item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: 27.w,
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              item.poster_pic!,
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
