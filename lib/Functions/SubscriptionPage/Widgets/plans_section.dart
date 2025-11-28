import 'package:flutter/material.dart';
import 'package:niri9/Functions/SubscriptionPage/Widgets/payment_widget.dart';
import 'package:niri9/Services/apple_iap_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import 'subscription_item.dart';

class PlansSection extends StatelessWidget {
  const PlansSection({
    super.key,
    required this.selected,
    required this.onTap,
    required this.upgrade,
    this.iapService, // Made optional to receive from parent
  });

  final int selected;
  final Function(int) onTap;
  final Function upgrade;
  final AppleIAPService? iapService; // Store the IAP service

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: 100.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 16.h,
            width: double.infinity,
            child: Consumer<Repository>(builder: (context, data, _) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var item = data.subscriptions[index];
                  return SubscriptionItem(
                    selected: selected,
                    item: item,
                    index: index,
                    onTap: () => onTap(index),
                    iapService: iapService, // Pass IAP service to child
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 2.w,
                  );
                },
                itemCount: data.subscriptions.length,
              );
            }),
          ),
          PaymentWidget(
            selected: selected,
            upgrade: () => upgrade(),
            iapService: iapService, // Pass IAP service for iOS prices
          ),
          SizedBox(
            height: 1.h,
          ),
        ],
      ),
    );
  }
}
