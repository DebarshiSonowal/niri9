import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/plan_pricing.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Widgets/gradient_text.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Repository/repository.dart';
import 'Widgets/plan_column.dart';
import 'Widgets/premium_card.dart';
import 'Widgets/subscription_appbar.dart';
import 'Widgets/type_column.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selected = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: const SubscriptionAppbar(),
      ),
      backgroundColor: Constants.subscriptionBg,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 2.h,
        ),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const PremiumCard(),
              SizedBox(
                height: 5.h,
              ),
              Consumer<Repository>(builder: (context, data, _) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 1.h,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  color: const Color(0xff0b071e),
                  width: double.infinity,
                  height: 42.5.h,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const TypeColumn(),
                              PlanColumn(
                                plan: data.plans,
                                index: 0,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                              PlanColumn(
                                plan: data.plans,
                                index: 1,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                              PlanColumn(
                                plan: data.plans,
                                index: 2,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 0.5.h,
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.planButtonColor,
                          ),
                          onPressed: () {},
                          child: Center(
                            child: Text(
                              "Continue",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: const Color(0xff002215),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Apply Promo Code',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          // fontWeight: FontWeight.bold,
                          fontSize: 9.sp,
                          decorationColor: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
