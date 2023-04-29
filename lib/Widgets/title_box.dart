import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Constants/constants.dart';

class TitleBox extends StatelessWidget {
  const TitleBox({
    super.key, this.text, required this.onTap,
  });
  final String? text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      width: double.infinity,
      height: 6.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text??""),
          GestureDetector(
            onTap: ()=>onTap(),
            child: Row(
              children: [
                Text(
                  "More",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    color: Constants.thirdColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Constants.thirdColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}