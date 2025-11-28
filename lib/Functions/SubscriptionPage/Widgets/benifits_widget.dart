import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import 'benefits_availability_item.dart';
import 'benefits_name.dart';
import 'benifits_item.dart';

class BenefitsWidget extends StatelessWidget {
  const BenefitsWidget({
    super.key,
    required this.selected,
  });

  final int? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: 100.w,
      child: Consumer<Repository>(builder: (context, data, _) {
        return BenefitsItem(selected: selected, data: data);
      }),
    );
  }
}
