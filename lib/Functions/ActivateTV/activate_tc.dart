import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Navigation/Navigate.dart';
import '../CategorySpecific/category_specific_screen.dart';

class ActivateTvScreen extends StatefulWidget {
  const ActivateTvScreen({super.key});

  @override
  State<ActivateTvScreen> createState() => _ActivateTvScreenState();
}

class _ActivateTvScreenState extends State<ActivateTvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(7.h),
          child: const CategorySpecificAppbar(searchTerm: "Activate TV")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                Assets.smartTV,
                color: Colors.white,
                scale: 2,
              ),
              SizedBox(
                height: 4.h,
              ),
              Text(
                "Activate NIRI9 on your TV",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                "Enter the activation code on your TV screen",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:5.w,
                ),
                child: OTPTextField(
                  length: 5,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 12.w,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: Colors.white54,
                    enabledBorderColor: Colors.white70,
                    // backgroundColor: Colors.white,
                    errorBorderColor: Colors.red,
                    focusBorderColor: Colors.blue,
                  ),
                  style: TextStyle(
                      fontSize: 15.sp,
                  ),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {
                    print("Completed: $pin");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
