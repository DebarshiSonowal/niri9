import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import 'benefits_availability_item.dart';
import 'benefits_name.dart';

class BenefitsItem extends StatelessWidget {
  const BenefitsItem({
    super.key,
    required this.selected,
    required this.data,
  });
  final Repository data;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    if (data.subscriptions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const BenefitsName(),
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < data.subscriptions.length; i++)
                  Expanded(
                    child: BenefitsAvailabilityItem(
                        selected: selected, i: i, data: data),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
