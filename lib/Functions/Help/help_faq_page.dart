import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(12.h),
        child: Container(
          color: Constants.backgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 4.h,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigation.instance.goBack();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_sharp,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Image.asset(
                    Assets.logoTransparent,
                    height: 7.5.h,
                    width: 14.w,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: 5.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Help & FAQ's",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Consumer<Repository>(
                builder: (context,data,_) {
                  return Html(
                    data:data.faq?? "",
                    // style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    //   color: Colors.white70,
                    // ),
                  );
                }
              ),
              // const Spacer(),
              // Image.asset(
              //   Assets.logoTransparent,
              //   height: 15.h,
              //   width: 30.w,
              //   fit: BoxFit.cover,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
