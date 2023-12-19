import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
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
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  bool visible = true, agree = false;
  CountryCode selectedCountryCode = CountryCode(name: 'IN', dialCode: "+91");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 5.h,
              ),
              Image.asset(
                Assets.logo,
                scale: 12,
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 7.h,
              ),
              Container(
                height: 50.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.white38,
                    width: 0.1.h,
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: 4.5.w),
                width: double.infinity,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  // padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25.w,
                        child: CountryCodePicker(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 0.3.h),
                          onChanged: _onCountryChange,
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: 'IN',
                          favorite: const ['+91', 'IN'],
                          // optional. Shows only country name and flag
                          showCountryOnly: false,
                          // optional. Shows only country name and flag when popup is closed.
                          showOnlyCountryWhenClosed: false,
                          // optional. aligns the flag and the Text left
                          alignLeft: false,
                          backgroundColor: Colors.black54,
                          dialogBackgroundColor: Colors.black54,
                          // flagWidth: 25.sp,
                        ),
                      ),
                      SizedBox(
                        height: 50.sp,
                        // width: 1.w,
                        child: VerticalDivider(
                          thickness: 1.sp,
                          color: Colors.white38,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          onSubmitted: (val) {},
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                            hintText: "Phone Number",
                            fillColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2.5.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 2.h,
                      child: Checkbox(
                        checkColor: Colors.blue,
                        fillColor: MaterialStateProperty.all(Colors.white10),
                        value: agree,
                        onChanged: (bool? value) {
                          setState(() {
                            agree = !agree;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                      width: 80.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8.5.sp,
                              ),
                              text: 'By proceeding you are agreeing to our ',
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                height: 5.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        side: BorderSide(color: Colors.white38),
                      ),
                    ),
                  ),
                  onPressed: () {
                    // loginByOTP(mobileController.text);
                    if (agree) {
                      if (mobileController.text.isNotEmpty &&
                          mobileController.text.length >= 10) {
                        debugPrint(
                            "nybe ${selectedCountryCode.dialCode} ${mobileController.text}");
                        if (selectedCountryCode.dialCode == "+91") {
                          Navigation.instance.navigate(
                            Routes.otpScreen,
                            args:
                                "${selectedCountryCode.dialCode}${mobileController.text.toString()}",
                          );
                        } else {
                          loginByFirebase(selectedCountryCode.dialCode,
                              mobileController.text.toString());
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Enter a valid mobile number");
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please agree to our terms & conditions");
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 4.w,
              //   ),
              //   height: 2.h,
              //   width: double.infinity,
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Divider(
              //           thickness: 0.05.h,
              //           color: Colors.white70,
              //         ),
              //       ),
              //       Container(
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 5.w,
              //         ),
              //         child: Text(
              //           "Or",
              //           style:
              //               Theme.of(context).textTheme.headlineSmall?.copyWith(
              //                     color: Colors.white,
              //                     fontSize: 12.sp,
              //                   ),
              //         ),
              //       ),
              //       Expanded(
              //         child: Divider(
              //           thickness: 0.05.h,
              //           color: Colors.white70,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: 5.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 4.5.w),
              //   child: SocialLoginButton(
              //     height: 5.h,
              //     width: double.infinity,
              //     buttonType: SocialLoginButtonType.google,
              //     onPressed: () {
              //       signInWithGoogle();
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      selectedCountryCode = countryCode;
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((UserCredential value) {
      return value;
    });
  }

  void loginByFirebase(dialcode, number) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.login(
      "firebase",
      // selectedCountryCode.dialCode.toString(),
      dialcode,
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
