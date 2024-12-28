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
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.h),
                    border: Border.all(
                      color: Colors.white38,
                      width: 0.3.h,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 4.5.w),
                  width: double.infinity,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        child: CountryCodePicker(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 0.5.h),
                          onChanged: _onCountryChange,
                          initialSelection: 'IN',
                          favorite: const ['+91', 'IN'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          backgroundColor: Colors.black54,
                          dialogBackgroundColor: Colors.black54,
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                        child: VerticalDivider(
                          thickness: 0.3.h,
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
                              fontSize: 12.sp,
                            ),
                            hintText: "Phone Number",
                            fillColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.5.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (bool? value) {
                          setState(() {
                            agree = value ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.all(Colors.white10),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Navigate to Terms & Conditions page
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                              children: [
                                TextSpan(
                                    text:
                                        'By proceeding you are agreeing to our '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.h),
                          side: BorderSide(color: Colors.white38, width: 0.3.h),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (agree) {
                        if (mobileController.text.isNotEmpty &&
                            mobileController.text.length >= 10) {
                          debugPrint(
                              "Attempting login with ${selectedCountryCode.dialCode} ${mobileController.text}");
                          if (selectedCountryCode.dialCode == "+91") {
                            setState(() {
                              isLoggedIn = false;
                            });
                            if (isIndianNumber(
                                "${selectedCountryCode.dialCode}${mobileController.text}")) {
                              sendOTP(mobileController.text);
                            } else {
                              phoneSignIn(phoneNumber: mobileController.text);
                            }
                          } else {
                            loginByFirebase(selectedCountryCode.dialCode,
                                mobileController.text);
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
                        fontSize: 14.sp,
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
                      borderRadius: BorderRadius.circular(1.h),
                      activeColor: Colors.white38,
                      fieldHeight: 6.5.h,
                      fieldWidth: 10.w,
                      activeFillColor: Colors.black,
                      selectedFillColor: Colors.black54,
                      selectedColor: Colors.white,
                      inactiveColor: Colors.grey.shade700,
                      inactiveFillColor: Colors.black54,
                    ),
                    textStyle:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                    hintCharacter: '0',
                    hintStyle:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey.shade300,
                              fontSize: 12.sp,
                            ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: otpController,
                    onCompleted: (v) {
                      debugPrint("OTP Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
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
                                "${selectedCountryCode.dialCode}${mobileController.text}")) {
                              sendOTP(mobileController.text);
                            } else {
                              phoneSignIn(phoneNumber: mobileController.text);
                            }
                          }
                        },
                        child: Text(
                          time != 0 ? "Resend OTP after 0:$time" : "Resend OTP",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
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
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.h),
                          side: BorderSide(color: Colors.white38, width: 0.3.h),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      debugPrint("Verified $_verificationId");
                      verifyOTP(
                          "${selectedCountryCode.dialCode}${mobileController.text}",
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
    final response = await ApiProvider.instance.login(
      "otp",
      mobile.substring(0, 3),
      mobile.substring(3),
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
    } else {
      showError(response.message ?? "Something Went Wrong");
    }
  }

  void verifyOTP(String mobile, String otp) async {
    debugPrint("OTP verification for $mobile");
    if (isIndianNumber(mobile)) {
      loginByOTP("${selectedCountryCode.dialCode}$mobile", otp);
    } else {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId ?? "", smsCode: otpController.text);
        await _auth.signInWithCredential(credential).then((value) {
          loginByOTP("${selectedCountryCode.dialCode}$mobile", "");
        });
      } on FirebaseAuthException catch (e) {
        debugPrint("FirebaseAuthException: ${e.code} ${e.message}");
        Navigation.instance.goBack();
        showError("${e.message}");
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
      debugPrint('error $error $stackTrace');
      Navigation.instance.goBack();
    }).then((value) {
      setState(() {
        time = 59;
      });
    });
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= 59) {
        if (mounted) {
          setState(() {
            timer.cancel();
          });
        } else {
          timer.cancel();
        }
      }
      if (mounted) {
        setState(() {
          time = (59 - timer.tick);
        });
      } else {
        time = (59 - timer.tick);
      }
    });
  }

  void _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    debugPrint('Verification completed ${authCredential.smsCode}');
    setState(() {
      otpController.text = authCredential.smsCode ?? "";
    });
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    Navigation.instance.goBack();
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
    showError("${exception.message}");
  }

  void _onCodeSent(String verification, int? forceResendingToken) {
    _verificationId = verification;
    debugPrint("Code sent $_verificationId");
    Fluttertoast.showToast(msg: "OTP sent successfully");
    Navigation.instance.goBack();
    setTimer();
  }

  void _onCodeTimeout(String timeout) {
    // Handle timeout if necessary
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(
              errorMessage,
              style: Theme.of(context).textTheme.headlineMedium,
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
    phoneNumber = phoneNumber.replaceAll(RegExp(r'^[+0]+'), '');
    return phoneNumber.startsWith('91');
  }
}
