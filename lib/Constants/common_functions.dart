import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Navigation/Navigate.dart';
import '../Router/routes.dart';
import '../Widgets/login_sheet_body.dart';

class CommonFunctions {
  Future<void> showLoginDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.black,
            title: Text(
              "Oops! You are not logged in",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 70.w,
                  height: 5.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      Text(
                        "You need to log in to view the videos",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDB2323),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigation.instance
                                .navigate(Routes.loginScreen, args: "");
                          },
                          child: Text(
                            "LOG IN",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            // actions: [

            // ],
          );
        });
  }

  void showNotSubscribedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Oops! You are not allowed to view it.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
          ),
          content: SizedBox(
            width: 70.w,
            height: 5.h,
            child: Center(
              child: Text(
                "You need to either buy a subscription or upgrade to a better plan",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigation.instance.navigate(Routes.subscriptionScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Adjust button color as needed
              ),
              child: Text(
                "Upgrade",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Adjust button color as needed
              ),
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void showLoginAndSubscribe(BuildContext context) {
  //   showModalBottomSheet(context: context, builder:(context) {
  //     return
  //   },);
  // }

  void showLoginSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        backgroundColor: Colors.black,
        builder: (context) {
          return const LoginSheetBody();
        });
  }
}
