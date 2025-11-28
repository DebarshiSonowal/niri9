import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Constants/constants.dart';

class TitleBox extends StatelessWidget {
  const TitleBox({
    super.key,
    this.text,
    required this.onTap,
    required this.isEnd,
  });
  final String? text;
  final Function onTap;
  final bool isEnd;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      child: Row(
        children: [
          // Refined accent bar
          Container(
            width: 3,
            height: 4.5.h,
            decoration: BoxDecoration(
              color: Constants.thirdColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 4.w),
          // Main content area
          Expanded(
            child: SizedBox(
              height: 4.5.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text ?? "",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  isEnd
                      ? GestureDetector(
                          onTap: () => onTap(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.5.h, horizontal: 1.w),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Constants.thirdColor.withOpacity(0.8),
                              size: 16.sp,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
