import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';

class BenefitsAvailabilityItem extends StatelessWidget {
  const BenefitsAvailabilityItem({
    super.key,
    required this.selected,
    required this.i,
    required this.data,
  });

  final int selected;
  final int i;
  final Repository data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected == i ? Colors.grey.shade900 : Colors.transparent,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
      height: 48.h,
      width: 15.w,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 4.h,
            // height:,
            child: Center(
              child: Text(
                data.subscriptions[i].title ?? "",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: checkConditions(data, data.subscriptions[i].id)
                          ? Colors.green
                          : Colors.white,
                      // fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              Icons.check,
              color: checkConditions(data, data.subscriptions[i].id)
                  ? Colors.green
                  : Colors.white,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              Icons.check,
              color:
                  (data.subscriptions[i].displayData?.watch_tv?.value ?? false)
                      ? checkConditions(data, data.subscriptions[i].id)
                          ? Colors.green
                          : Colors.white
                      : Colors.white30,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              Icons.check,
              color: (data.subscriptions[i].displayData?.ad?.value ?? false)
                  ? checkConditions(data, data.subscriptions[i].id)
                      ? Colors.green
                      : Colors.white
                  : Colors.white30,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Center(
              child: Text(
                '${data.subscriptions[i].displayData?.screens?.value ?? 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: checkConditions(data, data.subscriptions[i].id)
                          ? Colors.green
                          : Colors.white,
                      // fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Center(
              child: Text(
                data.subscriptions[i].displayData?.quality?.value ?? '720p',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: checkConditions(data, data.subscriptions[i].id)
                          ? Colors.green
                          : Colors.white,
                      // fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkConditions(Repository data, int? id) {
    if (data.user?.last_subscription ?? false) {
      return false;
    }
    if (data.user?.last_sub?.lastSubscription?.id == id) {
      return true;
    }
    return false;
  }
}
