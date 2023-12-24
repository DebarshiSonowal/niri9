import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Navigation/Navigate.dart';
import '../Router/routes.dart';

class CommonFunctions{

  void showLoginDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Oops! You are not logged in",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
            content: SizedBox(
              width: 70.w,
              height: 5.h,
              child: Center(
                child: Text(
                  "You need to log in to view the videos",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigation.instance.navigate(Routes.loginScreen);
                },
                child: Text(
                  "LOG IN",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          );
        });
  }

}