import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Repository/repository.dart';
import '../../../Widgets/gradient_text.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 13.w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Constants.subscriptionCardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 1.5.h,
          horizontal: 8.w,
        ),
        child: Column(
          children: [
            GradientText(
              "Premium",
              style: TextStyle(
                fontSize: 15.sp,
              ),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff7338b0),
                  Color(0xffb61d73),
                ],
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "INR 599",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(
              height: 2.5.h,
            ),
            Text(
              "For 365 Days",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white30,
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
              ),
            ),
            SizedBox(
              height: 2.5.h,
            ),
            Text(
              "Date of Purchase: 04 Jun 2022",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                // fontWeight: FontWeight.bold,
                fontSize: 9.sp,
              ),
            ),
            SizedBox(
              height: 2.5.h,
            ),
            Consumer<Repository>(builder: (context, data, _) {
              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var item = data.subscriptions[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width:15.w,
                          child: Text(
                            item.title ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: Colors.white30,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        Text(
                          item.value ?? "Active",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 0.01.h,
                    color: Colors.white,
                  );
                },
                itemCount: data.subscriptions.length,
              );
            }),
          ],
        ),
      ),
    );
  }
}