import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Models/video.dart';

class NumberedOttItem extends StatelessWidget {
  const NumberedOttItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.index,
  });

  final Video item;
  final Function onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 40.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Netflix-style large gradient number
            Container(
              width: 10.w,
              child: Stack(
                children: [
                  // Background text for shadow
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w900,
                      height: 0.8,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.shade300,
                            Colors.red.shade600,
                            Colors.red.shade800,
                            Colors.red.shade900,
                          ],
                          stops: [0.0, 0.3, 0.7, 1.0],
                        ).createShader(Rect.fromLTWH(0, 0, 200, 100)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 2.w),

            // Movie/show poster
            Expanded(
              child: Container(
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.profile_pic ?? "",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade900,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                Assets.logoTransparent,
                                opacity: AlwaysStoppedAnimation(0.3),
                                width: 15.w,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey.shade900,
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 8.w,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient overlay for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),

                      // Play icon overlay
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 6.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}