import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      final repo = Provider.of<Repository>(context, listen: false);

      // Run all non-dependent API calls in parallel for better performance
      final futures = <Future>[
        _fetchCategories(repo),
        _fetchGenres(repo),
        _fetchSettings(repo),
      ];

      // Add profile fetch only if user is logged in
      if (Storage.instance.isLoggedIn) {
        futures.add(_fetchProfile(repo));
      }

      // Wait for all API calls to complete
      await Future.wait(futures);

      if (!mounted) return;

      // Navigate to home screen
      Navigation.instance.navigateAndRemoveUntil(Routes.homeScreen);
    } catch (e) {
      debugPrint("Splash initialization error: $e");
      // Even if some calls fail, still navigate to home
      if (mounted) {
        Navigation.instance.navigateAndRemoveUntil(Routes.homeScreen);
      }
    }
  }

  Future<void> _fetchCategories(Repository repo) async {
    try {
      debugPrint("SplashScreen: Starting to fetch categories");
      final response = await ApiProvider.instance.getCategories();
      debugPrint(
          "SplashScreen: Categories API response - success: ${response.success}");
      debugPrint(
          "SplashScreen: Categories count: ${response.categories.length}");

      if (response.success ?? false) {
        debugPrint("SplashScreen: Setting categories in repository");
        for (int i = 0; i < response.categories.length; i++) {
          final category = response.categories[i];
          debugPrint(
              "SplashScreen: Category $i - name: '${category.name}', slug: '${category.slug}'");
        }
        repo.setCategories(response.categories);
        debugPrint("SplashScreen: Categories successfully set in repository");
      } else {
        debugPrint(
            "SplashScreen: Categories API returned success=false, message: ${response.message}");
      }
    } catch (e) {
      debugPrint("SplashScreen: Failed to fetch categories: $e");
    }
  }

  Future<void> _fetchGenres(Repository repo) async {
    try {
      final response = await ApiProvider.instance.getGenres();
      if (response.success ?? false) {
        repo.addGenres(response.genres);
      }
    } catch (e) {
      debugPrint("Failed to fetch genres: $e");
    }
  }

  Future<void> _fetchSettings(Repository repo) async {
    try {
      final response = await ApiProvider.instance.getSettings();
      if (response.success ?? false) {
        repo.setVideoPercent(response.videoPercent ?? []);
        repo.setVideoSettings(response.videoSetting);
        repo.addCategoryAll(response.categoryAll);
      }
    } catch (e) {
      debugPrint("Failed to fetch settings: $e");
    }
  }

  Future<void> _fetchProfile(Repository repo) async {
    try {
      final response = await ApiProvider.instance.getProfile();
      if (response.success ?? false && response.user != null) {
        repo.setUser(response.user!);
        debugPrint("User profile loaded: ${response.user?.last_sub}");
      }
    } catch (e) {
      debugPrint("Failed to fetch profile: $e");
    }
  }

  // Optionally enable this if Help Center is needed on launch
  // Future<void> _fetchHelp(Repository repo) async {
  //   final response = await ApiProvider.instance.getHelpCenter();
  //   if (response.success ?? false) {
  //     repo.setHelp(response.result ?? "");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151515),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
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
            SizedBox(height: 3.h),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
