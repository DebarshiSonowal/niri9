import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Helper/storage.dart';
import '../../Repository/repository.dart';
import '../../Widgets/alert.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.mobile});

  final String mobile;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? timer;

  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _verificationId;

  // final SmsAutoFill _autoFill = SmsAutoFill();
  String currentText = '';
  String time = '30';
  bool resend = false;

  @override
  void dispose() {
    otpController.dispose();
    try {
      timer?.cancel();
    } catch (e) {
      debugPrint(e.toString());
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      phoneSignIn(phoneNumber: widget.mobile.toString().substring(3));
    });
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
                height: 10.h,
              ),
              Image.asset(
                Assets.logo,
                scale: 12,
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 10.h,
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
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: _verificationId ?? "",
                              smsCode: otpController.text);
                      await _auth
                          .signInWithCredential(credential)
                          .then((value) {
                        loginByOTP(widget.mobile);
                        // Navigation.instance
                        //     .navigateAndRemoveUntil(Routes.homeScreen);
                      });
                    } on FirebaseAuthException catch (_, e) {
                      debugPrint(_.code);
                      // if(dev)
                      Navigation.instance.goBack();
                      showError("${_.message}");
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
            ],
          ),
        ),
      ),
    );
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
        time = '30';
        // setTimer();
      });
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

  void showError(String msg) {
    AlertX.instance.showAlert(
        title: "Error",
        msg: msg,
        positiveButtonText: "Done",
        positiveButtonPressed: () {
          Navigation.instance.goBack();
        });
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 30) {
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
            time = (30 - timer.tick).toString();
          });
        } catch (e) {
          debugPrint(e.toString());
          time = (30 - timer.tick).toString();
        }
      } else {
        debugPrint(timer.tick.toString());
        time = (30 - timer.tick).toString();
      }
      // print("Dekhi 5 sec por por kisu hy ni :/");
    });
  }

  void loginByOTP(String mobile) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.login(
        "mobile",
        // selectedCountryCode.dialCode.toString(),
        mobile.toString().substring(0, 3),
        mobile.toString().substring(3),
        "",
        "",
        "",
        "",
        "",
        "");
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
}
