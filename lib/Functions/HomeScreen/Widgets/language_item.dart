
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
        child: Container(
          padding: EdgeInsets.only(
            right: 0.4.w,
          ),
          height: 11.h,
          width: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                Assets.assameseImage,
                height: 11.h,
                width: 20.w,
                fit: BoxFit.fitHeight,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.slug ?? "",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    item.name ?? "",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}