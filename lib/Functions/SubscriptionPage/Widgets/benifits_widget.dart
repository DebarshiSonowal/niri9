
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import 'benefits_availability_item.dart';
import 'benefits_name.dart';

class BenefitsWidget extends StatelessWidget {
  const BenefitsWidget({
    super.key,
    required this.selected,
  });

  final int selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: 100.w,
      child: Consumer<Repository>(builder: (context, data, _) {
        return BenefitsItem(selected: selected,data:data);
      }),
    );
  }
}

class BenefitsItem extends StatelessWidget {
  const BenefitsItem({
    super.key,
    required this.selected, required this.data,
  });
  final Repository data;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const BenefitsName(),
        SizedBox(
          width: 60.w,
          height: 48.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < data.subscriptions.length; i++)
                BenefitsAvailabilityItem(selected: selected, i: i, data: data),
            ],
          ),
        ),
      ],
    );
  }
}

