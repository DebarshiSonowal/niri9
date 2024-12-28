import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Models/appbar_option.dart';

class CustomAppbarItem extends StatelessWidget {
  const CustomAppbarItem({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
  });

  final int index;
  final AppBarOption item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: SizedBox(
        width: 16.w,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              (index == 0 || index == 2)
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      height: 19.sp,
                      width: 19.sp,
                      // color: Colors.white,
                    )
                  : CachedNetworkImage(
                      imageUrl: item.image!,
                      height: 19.sp,
                      width: 19.sp,
                      // color: Colors.white,
                    ),
              SizedBox(
                height: 0.4.h,
              ),
              SizedBox(
                width: 15.w,
                child: Center(
                  child: Text(
                    item.name ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
