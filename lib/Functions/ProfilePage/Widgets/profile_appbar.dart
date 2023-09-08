import 'package:flutter/material.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Constants/constants.dart';

class ProfileAppbar extends StatelessWidget {
  const ProfileAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.primaryColor,
      child: Column(
        children: [
          SizedBox(
            height: 3.h,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigation.instance.goBack();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                Assets.logoTransparent,
                height: 7.5.h,
                width: 14.5.w,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
