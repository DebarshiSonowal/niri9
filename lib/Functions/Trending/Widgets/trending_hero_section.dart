import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';

class TrendingHeroSection extends StatefulWidget {
  const TrendingHeroSection({super.key});

  @override
  State<TrendingHeroSection> createState() => _TrendingHeroSectionState();
}

class _TrendingHeroSectionState extends State<TrendingHeroSection> {
  @override
  void initState() {
    super.initState();
    fetchTrendingBanner();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(
      builder: (context, data, _) {
        if (data.trendingBanner.isEmpty) {
          return Container(
            width: double.infinity,
            height: 50.h,
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final item = data.trendingBanner.first;

        return Container(
          width: double.infinity,
          height: 30.h,
          child: Stack(
            children: [
              // Background image with better aspect ratio
              CachedNetworkImage(
                imageUrl: item.posterPic ?? "",
                fit: BoxFit.cover,
                // height: 50.h,
                width: double.infinity,
                placeholder: (context, index) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: Image.asset(
                        Assets.logoTransparent,
                        opacity: const AlwaysStoppedAnimation(0.3),
                        width: 25.w,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 20.w,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),

              // Cleaner gradient overlay
              Container(
                margin: EdgeInsets.only(top: 20.h),
                height:10.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4, 0.7, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              // Top trending badge - repositioned
              Positioned(
                top: 2.h,
                left: 4.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 #1 TRENDING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Content overlay - better positioned
              Positioned(
                bottom: 1.h,
                left: 4.w,
                right: 4.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with better typography
                    Text(
                      item.title ?? "Featured Content",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Subtitle/genre info
                    if (item.description?.isNotEmpty ?? false)
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 1.h),

                    // Redesigned action buttons
                    Row(
                      children: [
                        // Play button - more prominent
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () {
                              if (Storage.instance.isLoggedIn) {
                                Navigation.instance.navigate(
                                  Routes.watchScreen,
                                  args: item.id,
                                );
                              } else {
                                CommonFunctions().showLoginDialog(context);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Play',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // My List button - more subtle
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () {
                              if (Storage.instance.isLoggedIn) {
                                addToMyList(item.id);
                              } else {
                                Navigation.instance.navigate(
                                  Routes.loginScreen,
                                  args: "",
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'My List',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // Share button - cleaner design
                        GestureDetector(
                          onTap: () {
                            Share.share(
                              'Check out NIRI9 from https://play.google.com/store/apps/details?id=com.niri.niri9',
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchTrendingBanner() async {
    final response = await ApiProvider.instance.getBannerResponse("home");
    if (response.success ?? false) {
      if (mounted) {
        Provider.of<Repository>(context, listen: false)
            .addTrendingBanner(response.result ?? []);
      }
    }
  }

  Future<void> addToMyList(int? id) async {
    final response = await ApiProvider.instance.addMyVideos(id);
    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Added To My List");
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
    }
  }
}