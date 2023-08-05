import 'package:flutter/material.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(
      builder: (context,data,_) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 2.h,
          ),
          height: 12.h,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data.videoDetails?.title}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(
                height: 12.sp,
              ),
              Text(
                "${data.videoDetails?.season_txt} . ${data.videoDetails?.type_name} . ${data.videoDetails?.category_name}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}