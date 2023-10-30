import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:sizer/sizer.dart';

import '../SubscriptionPage/Widgets/custom_cupon_card.dart';
import '../SubscriptionPage/Widgets/subscription_appbar.dart';

class ApplyCuponsPage extends StatefulWidget {
  const ApplyCuponsPage({super.key});

  @override
  State<ApplyCuponsPage> createState() => _ApplyCuponsPageState();
}

class _ApplyCuponsPageState extends State<ApplyCuponsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: const SubscriptionAppbar(
          title: "Promo Code",
        ),
      ),
      backgroundColor: Constants.primaryColor,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
        width: double.infinity,
        height: double.infinity,
        child: const Column(
          children: [
            CustomCuponCard(),
          ],
        ),
      ),
    );
  }
}


