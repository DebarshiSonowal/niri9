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

  final int? selected;
  final int i;
  final Repository data;

  @override
  Widget build(BuildContext context) {
    // Add safety check for valid subscription index
    if (i >= data.subscriptions.length) {
      return Container(
        height: 48.h,
        width: 15.w,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final subscription = data.subscriptions[i];
    final isActive = checkConditions(data, subscription.id);

    return Container(
      decoration: BoxDecoration(
        color: selected == i
            ? Colors.blue.shade900.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected == i
            ? Border.all(color: Colors.blue.shade400.withOpacity(0.5), width: 1)
            : null,
      ),
      height: 48.h,
      width: 15.w,
      child: Column(
        children: [
          // Plan title
          SizedBox(
            width: double.infinity,
            height: 4.h,
            child: Center(
              child: Text(
                subscription.title ?? "",
                style: TextStyle(
                  color: isActive ? Colors.green.shade300 : Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // All Content
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              Icons.check_circle,
              color: isActive ? Colors.green.shade400 : Colors.white,
              size: 20.sp,
            ),
          ),

          // Watch TV
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              (subscription.displayData?.watch_tv?.value ?? false)
                  ? Icons.check_circle
                  : Icons.cancel,
              color: (subscription.displayData?.watch_tv?.value ?? false)
                  ? (isActive ? Colors.green.shade400 : Colors.white)
                  : Colors.grey.shade600,
              size: 20.sp,
            ),
          ),

          // Ad-Free
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Icon(
              (subscription.displayData?.ad?.value ?? false)
                  ? Icons.check_circle
                  : Icons.cancel,
              color: (subscription.displayData?.ad?.value ?? false)
                  ? (isActive ? Colors.green.shade400 : Colors.white)
                  : Colors.grey.shade600,
              size: 20.sp,
            ),
          ),

          // Number of devices
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.shade400.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${subscription.displayData?.screens?.value ?? 1}',
                  style: TextStyle(
                    color: isActive ? Colors.green.shade300 : Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Video quality
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.shade400.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subscription.displayData?.quality?.value ?? '720p',
                  style: TextStyle(
                    color: isActive ? Colors.green.shade300 : Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkConditions(Repository data, int? id) {
    // Check if user has subscription and this plan matches their current subscription
    if (data.user?.has_subscription ?? false) {
      final currentSubId = data.user?.last_sub?.lastSubscription?.id;
      return currentSubId == id;
    }
    return false;
  }
}
