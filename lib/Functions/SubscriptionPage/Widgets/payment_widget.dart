import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';

class PaymentWidget extends StatelessWidget {
  const PaymentWidget({
    super.key,
    required this.selected,
    required this.upgrade,
  });

  final int selected;
  final Function upgrade;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30.w,
          height: 6.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "You Pay",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "₹",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                  ),
                  Consumer<Repository>(builder: (context, data, _) {
                    return AnimatedDigitWidget(
                      duration: const Duration(seconds: 1),
                      value: data.subscriptions[selected].total_price_inr ?? 0,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        Spacer(),
        SizedBox(
          width: 55.w,
          height: 4.5.h,
          child: ElevatedButton(
            onPressed: () => upgrade(),
            child: Text(
              "Upgrade",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
