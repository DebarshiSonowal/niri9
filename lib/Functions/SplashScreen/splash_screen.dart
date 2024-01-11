import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.red,
              child: Image.asset(
                Assets.logoTransparent,
                height: 15.h,
                width: 40.w,
                fit: BoxFit.cover,
              ),
            ),
            // SizedBox(
            //   height: 1.h,
            // ),
            // SizedBox(
            //   height: 3.5.h,
            //   width: 7.w,
            //   child: const CircularProgressIndicator(
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      await fetchData();
    });
  }

  Future<void> fetchData() async {
    await fetchCategories();
    // await fetchBanner();
    await fetchGenres();
    // await fetchSections();
    // await fetchPrivacy();
    // await fetchRefund();
    // await fetchFaq();
    // await fetchHelp();
    // await fetchTerms();
    if(Storage.instance.isLoggedIn){
      await fetchProfile();
    }
    await fetchSettings();
    Navigation.instance.navigateAndRemoveUntil(Routes.homeScreen);
  }

  Future<void> fetchProfile() async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getProfile();
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      debugPrint("User: ${response.user?.last_sub}");
    } else {
      // Navigation.instance.goBack();
      // showError(response.message ?? "Something went wrong");
    }
  }
  // Future<void> fetchBanner() async {
  //   final response = await ApiProvider.instance.getBannerResponse("home");
  //   if (response.success ?? false) {
  //     // if (!context.mounted) return;
  //     Provider.of<Repository>(context, listen: false)
  //         .addHomeBanner(response.result??[]);
  //     // await fetchVideos(response.sections[0]);
  //   }
  // }

  // Future<void> fetchSections() async {
  //   final response = await ApiProvider.instance.getSections("home",'1');
  //   if (response.status ?? false) {
  //     // if (!context.mounted) return;
  //     Provider.of<Repository>(context, listen: false)
  //         .addHomeSections(response.sections);
  //     // await fetchVideos(response.sections[0]);
  //   }
  //   final response1 = await ApiProvider.instance.getSections("trending",'1');
  //   if (response1.status ?? false) {
  //     // if (!context.mounted) return;
  //     Provider.of<Repository>(context, listen: false)
  //         .addTrendingSections(response1.sections);
  //     // await fetchVideos(response.sections[0]);
  //   }
  // }

  Future<void> fetchCategories() async {
    final response = await ApiProvider.instance.getCategories();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setCategories(response.categories);
    }
  }

  Future<void> fetchGenres() async {
    final response = await ApiProvider.instance.getGenres();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .addGenres(response.genres);
    }
  }

  Future<void> fetchVideos(section) async {
    // final response = await ApiProvider.instance.getVideos(1, section, "movie", "action");
    // if(response.success??false){
    //   Provider.of<Repository>(context,listen: false).setVideos(response.videos);
    // }
  }

  // Future<void> fetchPrivacy() async {
  //   final response = await ApiProvider.instance.getPrivacyPolicy();
  //   if (response.success ?? false) {
  //     Provider.of<Repository>(context, listen: false)
  //         .setPrivacy(response.result ?? "");
  //   }
  // }
  // Future<void> fetchRefund() async {
  //   final response = await ApiProvider.instance.getRefundPolicy();
  //   if (response.success ?? false) {
  //     Provider.of<Repository>(context, listen: false)
  //         .setRefund(response.result ?? "");
  //   }
  // }
  Future<void> fetchHelp() async {
    final response = await ApiProvider.instance.getHelpCenter();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setHelp(response.result ?? "");
    }
  }
  // Future<void> fetchFaq() async {
  //   final response = await ApiProvider.instance.getFAQ();
  //   if (response.success ?? false) {
  //     Provider.of<Repository>(context, listen: false)
  //         .setFaq(response.result ?? "");
  //   }
  // }
  // Future<void> fetchTerms() async {
  //   final response = await ApiProvider.instance.getTermsPolicy();
  //   if (response.success ?? false) {
  //     Provider.of<Repository>(context, listen: false)
  //         .setTermsConditions(response.result ?? "");
  //   }
  // }

  Future<void> fetchSettings() async {
    final response = await ApiProvider.instance.getSettings();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setVideoPercent(response.videoPercent??[]);
      Provider.of<Repository>(context, listen: false)
          .setVideoSettings(response.videoSetting);
      Provider.of<Repository>(context, listen: false)
          .addCategoryAll(response.categoryAll);
    }
  }
}
