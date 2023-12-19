import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/languages.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/available_language.dart';

class LanguageItem extends StatelessWidget {
  const LanguageItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Language item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          //set border radius more than 50% of height and width to make circle
        ),
        child: Container(
          padding: EdgeInsets.only(
            right: 0.4.w,
          ),
          height: 11.h,
          width: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: CachedNetworkImageProvider(
                item.profile_pic ?? "",
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CachedNetworkImage(
              //   imageUrl: item.profile_pic??"",
              //   height: 5.h,
              //   width: 13.5.w,
              //   fit: BoxFit.fitHeight,
              // ),
              SizedBox(
                width: 4.w,
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Text(
              //       item.name ?? "",
              //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              //         color: Colors.white,
              //       ),
              //     ),
              //     Text(
              //       item.local_name ?? "",
              //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              //         color: Colors.white,
              //       ),
              //     ),
              //   ],
              // ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
