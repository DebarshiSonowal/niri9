import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Navigation/Navigate.dart';

class SubscriptionAppbar extends StatelessWidget {
  const SubscriptionAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          SizedBox(
            width: 4.w,
          ),
          IconButton(
            onPressed: () {
              Navigation.instance.goBack();
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white70,
              size: 16.sp,
            ),
          ),
          SizedBox(
            width: 21.5.w,
          ),
          Text(
            "Subscription",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white54,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}