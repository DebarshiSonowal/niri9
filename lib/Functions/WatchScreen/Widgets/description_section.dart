import 'package:flutter/material.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        bottom: 0.5.h,
        top: 1.5.h,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Audio Language",
                style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontSize: 9.sp,
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              Text(
                "Assamese",
                style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Constants.thirdColor,
                  fontSize: 9.sp,
                ),
              ),
              const Spacer(),
              Text(
                "Available in 1 language",
                style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white30,
                  fontSize: 9.sp,
                ),
              ),
              SizedBox(
                width: 1.w,
              ),
            ],
          ),
          SizedBox(
            height: 1.5.h,
          ),
          ReadMoreText(
            'What would you give to turn back time? A yong passionate group of boxers being trained by a renowned retired boxer,'
                'living their perfect little lives until one day everything startst of a deawa ',
            numLines: 2,
            readMoreText: '',
            readLessText: '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white30,
              fontSize: 9.sp,
            ),
            readMoreTextStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Constants.thirdColor,
              fontSize: 9.sp,
            ),
            readMoreIcon: const Icon(
              Icons.keyboard_arrow_down_sharp,
              color: Constants.thirdColor,
            ),
            readLessIcon:const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Constants.thirdColor,
            ),
          ),
        ],
      ),
    );
  }
}