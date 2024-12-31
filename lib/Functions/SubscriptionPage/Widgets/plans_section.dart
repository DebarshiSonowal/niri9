import 'package:flutter/material.dart';
import 'package:niri9/Functions/SubscriptionPage/Widgets/payment_widget.dart';
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
  });

  final int selected;
  final Function(int) onTap;
  final Function upgrade;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25.h,
      width: 100.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 14.h,
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
          ),
        ],
      ),
    );
  }
}
