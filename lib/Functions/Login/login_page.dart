import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import '../../Widgets/alert.dart';

class LoginPage extends StatefulWidget {
  final String? fromwhere;
  const LoginPage({super.key, this.fromwhere});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();
  bool agree = false;
  CountryCode selectedCountryCode = CountryCode(name: 'IN', dialCode: "+91");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Added background color for better contrast
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Image.asset(
                Assets.logo,
                height: 15.h, // Adjusted height for better visibility
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.white38,
                  width: 0.2.h,
                ),
              ),
              child: Row(
                children: [
                  CountryCodePicker(
                    onChanged: _onCountryChange,
                    initialSelection: 'IN',
                    favorite: const ['+91', 'IN'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    backgroundColor: Colors.transparent,
                    dialogBackgroundColor: Colors.black54,
                    textStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  VerticalDivider(
                    thickness: 1.sp,
                    color: Colors.white38,
                  ),
                  Expanded(
                    child: TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Phone Number",
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Checkbox(
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (!agree) {
                      return Colors.grey;
                    }
                    return Colors.white10;
                  }),
                  checkColor: Colors.blue,
                  value: agree,
                  onChanged: (bool? value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        agree = !agree;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                        text: 'By proceeding you are agreeing to our ',
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            SizedBox(
              width: double.infinity,
              height: 4.5.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white38),
                  ),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Divider(
              color: Colors.white70,
              thickness: 0.1.h,
            ),
            SizedBox(height: 2.h),
            Platform.isAndroid
                ? SizedBox(
                    height: 5.h,
                    width: double.infinity,
                    child: SocialLoginButton(
                      buttonType: SocialLoginButtonType.google,
                      onPressed: signInWithGoogle,
                      borderRadius: 8,
                      // padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      selectedCountryCode = countryCode;
    });
  }

  void _handleSubmit() {
    if (agree) {
      if (mobileController.text.isNotEmpty &&
          mobileController.text.length >= 10) {
        debugPrint(
            "nybe ${selectedCountryCode.dialCode} ${mobileController.text}");
        if (selectedCountryCode.dialCode == "+91") {
          Navigation.instance.navigate(
            Routes.otpScreen,
            args: {
              "mobile":
                  "${selectedCountryCode.dialCode}${mobileController.text}",
              "whereToGo": "sub"
            },
          );
        } else {
          loginByFirebase(
              selectedCountryCode.dialCode ?? "", mobileController.text);
        }
      } else {
        Fluttertoast.showToast(msg: "Enter a valid mobile number");
      }
    } else {
      Fluttertoast.showToast(msg: "Please agree to our terms & conditions");
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Get the GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      // Return null if the user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  void loginByFirebase(String dialCode, String number) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.login(
      "firebase",
      dialCode,
      number,
      "",
      "",
      "",
      "",
      "",
      "",
      Provider.of<Repository>(context, listen: false).firebase_otp_key,
    );
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Storage.instance.setUser(response.token ?? "");
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      Navigation.instance.navigate(Routes.homeScreen);
    } else {
      Navigation.instance.goBack();
      showError(response.message ?? "Something Went Wrong");
    }
  }

  void showError(String msg) {
    AlertX.instance.showAlert(
        title: "Error",
        msg: msg,
        positiveButtonText: "Done",
        positiveButtonPressed: () {
          Navigation.instance.goBack();
        });
  }
}
