import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../API/api_provider.dart';
import '../Helper/storage.dart';
import '../Navigation/Navigate.dart';
import '../Repository/repository.dart';
import '../Router/routes.dart';
import 'alert.dart';

class LoginSheetBody extends StatefulWidget {
  const LoginSheetBody({super.key});

  @override
  State<LoginSheetBody> createState() => _LoginSheetBodyState();
}

class _LoginSheetBodyState extends State<LoginSheetBody> {
  CountryCode selectedCountryCode = CountryCode(name: 'IN', dialCode: "+91");
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  bool visible = true, agree = false, isLoggedIn = true, resend = false;
  int time = 59;
  String currentText = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? timer;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 3.w,
        right: 3.w,
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      width: double.infinity,
      // height: 35.h,
      child: isLoggedIn
          ? Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 2.h,
          ),
          Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            height: 40.sp,
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
                  width: 8.w,
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
                  height: 5.h,
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
                      setState(() {
                        isLoggedIn = false;
                      });
                      if (isIndianNumber("${selectedCountryCode.dialCode}${mobileController.text.toString()}")) {
                        sendOTP(mobileController.text.toString());
                      } else {
                        phoneSignIn(phoneNumber: mobileController.text.toString());
                      }
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
        ],
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: PinCodeTextField(
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.phone,
              cursorColor: Colors.white,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                activeColor: Colors.white38,
                fieldHeight: 6.5.h,
                fieldWidth: 10.w,
                activeFillColor: Colors.black,
                selectedFillColor: Colors.black54,
                selectedColor: Colors.white,
                inactiveColor: Colors.grey.shade700,
                inactiveFillColor: Colors.black54,
              ),

              textStyle: Theme.of(context).textTheme.headline5?.copyWith(
                color: Colors.white,
              ),
              hintCharacter: '0',
              hintStyle: Theme.of(context).textTheme.headline5?.copyWith(
                color: Colors.grey.shade300,
                fontSize: 2.h,
              ),
              animationDuration: const Duration(milliseconds: 300),
              // backgroundColor: Colors.blue.shade50,
              enableActiveFill: true,
              // errorAnimationController: errorController,
              controller: otpController,
              onCompleted: (v) {
                debugPrint("Completed ");
              },
              onChanged: (value) {
                debugPrint(value);
                setState(() {
                  currentText = value;
                });
              },
              beforeTextPaste: (text) {
                debugPrint("Allowing to paste $text");
                setState(() {});
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
              appContext: context,
            ),
          ),
          SizedBox(
            height: 5.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (time == 0) {
                      if (isIndianNumber(
                          "${selectedCountryCode.dialCode}${mobileController.text.toString()}")) {
                        sendOTP(mobileController.text.toString());
                      } else {
                        phoneSignIn(
                            phoneNumber:
                            mobileController.text.toString());
                      }
                    }
                  },
                  child: Text(
                    time != 0 ? "Resend OTP after 0:$time" : "Resend OTP",
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
              onPressed: () async {
                debugPrint("Verified $_verificationId");
                verifyOTP(
                    "${selectedCountryCode.dialCode}${mobileController.text.toString()}",
                    otpController.text);
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
        ],
      ),
    );
  }

  void sendOTP(String mobile) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.generateOTP(mobile);
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Fluttertoast.showToast(msg: "OTP sent successfully");
      setTimer();
    } else {
      Navigation.instance.goBack();
      showError(response.message ?? "Something Went Wrong");
    }
  }

  void loginByOTP(String mobile, String otp) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.login(
      "otp",
      // selectedCountryCode.dialCode.toString(),
      mobile.toString().substring(0, 3),
      mobile.toString().substring(3),
      "",
      "",
      "",
      "",
      "",
      "",
      otp,
    );
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Storage.instance.setUser(response.token ?? "");
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      // Navigation.instance.navigate(Routes.homeScreen);
    } else {
      // Navigation.instance.goBack();
      showError(response.message ?? "Something Went Wrong");
    }
  }

  void verifyOTP(String mobile, String otp) async {
    debugPrint("OTP's ${isIndianNumber(otp)}");
    if (isIndianNumber(mobile)) {
      loginByOTP(
          "${selectedCountryCode.dialCode}${mobileController.text.toString()}",
          otp);
    } else {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId ?? "", smsCode: otpController.text);
        await _auth.signInWithCredential(credential).then((value) {
          loginByOTP(
              "${selectedCountryCode.dialCode}${mobileController.text.toString()}",
              "");
          // Navigation.instance
          //     .navigateAndRemoveUntil(Routes.homeScreen);
        });
      } on FirebaseAuthException catch (_, e) {
        debugPrint("the error is ${_.code} ${_.message} ${e}");
        // if(dev)
        Navigation.instance.goBack();
        showError("${_.message}");
      }
    }
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    debugPrint('+91$phoneNumber');
    Navigation.instance.navigate(Routes.loadingScreen);
    await _auth
        .verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout)
        .onError((error, stackTrace) {
      debugPrint('error ${error} ${stackTrace}');
      Navigation.instance.goBack();
    }).then((value) {
      setState(() {
        time = 59;
        // setTimer();
      });
    });
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 59) {
        try {
          if (mounted) {
            setState(() {
              timer.cancel();
            });
          } else {
            timer.cancel();
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      if (mounted) {
        debugPrint(timer.tick.toString());
        try {
          setState(() {
            time = (59 - timer.tick);
          });
        } catch (e) {
          debugPrint(e.toString());
          time = (59 - timer.tick);
        }
      } else {
        debugPrint(timer.tick.toString());
        time = (59 - timer.tick);
      }
      // print("Dekhi 5 sec por por kisu hy ni :/");
    });
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    // print("verification completed ${authCredential.smsCode}");
    // User? user = FirebaseAuth.instance.currentUser;
    debugPrint('Verification completed ${authCredential.smsCode}');
    setState(() {
      otpController.text = authCredential.smsCode!;
    });
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    Navigation.instance.goBack();
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }

    showError("${exception.message}");
  }

  _onCodeSent(String verification, int? forceResendingToken) {
    _verificationId = verification;
    // debugPrint(forceResendingToken);
    debugPrint(forceResendingToken.toString());
    debugPrint("code sent $_verificationId");
    Fluttertoast.showToast(msg: "OTP sent successfully");
    Navigation.instance.goBack();
    setTimer();
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(
              errorMessage,
              style: Theme.of(context).textTheme.headline4,
            ),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }).then((value) {
      // setState(() {
      //   isLoading = false;
      // });
    });
  }

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      selectedCountryCode = countryCode;
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
      // Navigation.instance.navigate(Routes.homeScreen);
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

  bool isIndianNumber(String phoneNumber) {
    // Remove any leading '+' or '0' from the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'^[+0]+'), '');

    // Check if the phone number starts with '91'
    return phoneNumber.startsWith('91');
  }
}
