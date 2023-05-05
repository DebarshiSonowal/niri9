import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RentBottomSheet extends StatelessWidget {
  const RentBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 95.h,
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 2.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Illegal",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              "Web Series.10- Dec- 2019 . Season 1",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xffececec),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Validity",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                      Text(
                        "15 days",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 0.2.h,
                    color: const Color(0xffc1c1c1),
                  ),
                  Text(
                    "You have 15 days to start watching this content once rented",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xffececec),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Watch Time",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                      Text(
                        "50 hours",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 0.2.h,
                    color: const Color(0xffc1c1c1),
                  ),
                  Text(
                    "You have 15 days to start watching this content once rented",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
            ),
            BulletedList(
              bullet: Container(
                height: 1.5.w,
                width: 1.5.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54),
                ),
              ),
              listItems: const [
                'You can watch the content multiple times within the 50 hours period.',
                'This is a non-refundable transaction',
                'This is content is only available for rent and not a part of Premium Subscription',
                'You can play your content on this device/ Niri9 Account only'
              ],
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xffececec),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 45.w,
                    child: Text(
                      "By renting you agree to our Terms of Use",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.black,
                                // fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  SizedBox(
                    width: 30.w,
                    height: 5.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff1b5fbd),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // <-- Radius
                        ),
                      ),
                      child: Text(
                        'Rent for ₹ 59',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
