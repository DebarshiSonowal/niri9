import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    // Get current user data and pre-fill the form
    final userResponse = await ApiProvider.instance.getProfile();
    if (userResponse.success ?? false) {
      setState(() {
        emailController.text = userResponse.user?.email ?? '';
        fnameController.text = userResponse.user?.f_name ?? '';
        lnameController.text = userResponse.user?.l_name ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10.h),
        child: Column(
          children: [
            SizedBox(
              height: 4.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start ,
              children: [
                // SizedBox(
                //   width: 2.w,
                // ),
                IconButton(
                  onPressed: () {
                    Navigation.instance.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 32.w,
                ),
                Image.asset(
                  Assets.logoTransparent,
                  height: 7.5.h,
                  width: 14.w,
                  fit: BoxFit.cover,
                ),
                // SizedBox(
                //   width: 2.w,
                // ),
                // SizedBox(
                //   width: 1.w,
                // ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.5.h,
        ),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Update Profile",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(
                height: 4.h,
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              else ...[
                TextFormField(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                  controller: fnameController,
                  keyboardType: TextInputType.name,
                  maxLines: null,
                minLines: 1,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Enter your First Name',
                  labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                    border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                  controller: lnameController,
                  keyboardType: TextInputType.name,
                  maxLines: null,
                minLines: 1,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Enter your Last Name',
                  labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                    border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                  controller: emailController,
                keyboardType: TextInputType.emailAddress,
                maxLines: null,
                minLines: 1,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Enter your Email',
                  labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                    border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(),
                ),
              ),
              ],
              SizedBox(
                height: 6.h,
              ),
              SizedBox(
                width: double.infinity,
                height: 6.h,
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
                    if (emailController.text.isNotEmpty ||
                        fnameController.text.isNotEmpty ||
                        lnameController.text.isNotEmpty) {
                      updateProfile(emailController.text, fnameController.text,
                          lnameController.text);
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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

  void updateProfile(String email, String fname, String lname) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response =
        await ApiProvider.instance.updateProfile(email, fname, lname);
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Fluttertoast.showToast(msg: response.message ?? "Profile updated");
      Navigation.instance.goBack();
    } else {
      Navigation.instance.goBack();
      Fluttertoast.showToast(
          msg: response.message ?? "Profile update unsuccessful");
    }
  }
}
