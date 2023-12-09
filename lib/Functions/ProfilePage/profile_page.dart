import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Repository/repository.dart';
import '../../Widgets/alert.dart';
import '../SubscriptionPage/Widgets/premium_card.dart';
import 'Widgets/profile_appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.h),
        child: const ProfileAppbar(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 1.h,
        ),
        child: Consumer<Repository>(builder: (context, data, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 4.h,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://plus.unsplash.com/premium_photo-1664540415069-bc45ce3e711e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80",
                  height: 20.h,
                  width: 20.h,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                "${data.user?.f_name} ${data.user?.l_name}",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      "Email:",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      data.user?.email??"N/A",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      "Mobile:",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      "${data.user?.mobile??"N/A"}",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.sp,),
                child: Text(
                  "Current Subscription",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              const PremiumCard(),
            ],
          );
        }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (Storage.instance.isLoggedIn??false) {
        fetchProfile(context);
      }
    });
  }

  void fetchProfile(BuildContext context) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getProfile();
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
    } else {
      Navigation.instance.goBack();
      showError(response.message ?? "Something went wrong");
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
