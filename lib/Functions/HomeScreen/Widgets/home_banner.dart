import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Functions/HomeScreen/Widgets/my_list_button.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/animation_add_button.dart';
import 'package:niri9/Models/banner.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../Trending/Widgets/trending_banner.dart';
import 'share_indicator.dart';
import 'slider_indicator.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchBanner(context),
        builder: (context, _) {
          if (_.hasData && (_.data ?? false) == true) {
            return BannerSection(
              fetchData: () {
                setState(() {
                  fetchBanner(context);
                });
              },
            );
          }
          if (_.hasData && (_.data ?? false) == false) {
            return Container();
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: 25.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
            ),
          );
        });
  }

  Future<bool> fetchBanner(context) async {
    final response = await ApiProvider.instance.getBannerResponse("home");
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .addHomeBanner(response.result ?? []);
      return true;
      // await fetchVideos(response.sections[0]);
    } else {
      return false;
    }
  }
}

class BannerSection extends StatefulWidget {
  const BannerSection({super.key, required this.fetchData});

  final Function fetchData;

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _current = 0;
  final CarouselSliderController controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      // height: 30.h,
      child: Consumer<Repository>(builder: (context, data, _) {
        return Stack(
          children: [
            data.homeBanner.isNotEmpty
                ? SizedBox(
                    // height: 44.h,
                    width: double.infinity,
                    child: CarouselSlider.builder(
                      carouselController: controller,
                      itemCount: data.homeBanner.length,
                      itemBuilder:
                          (BuildContext context, int index, int realIndex) {
                        var item = data.homeBanner[index];
                        return BannerImageItem(
                          item: item,
                          onTap: (int? val) {
                            if (Storage.instance.isLoggedIn) {
                              Navigation.instance
                                  .navigate(Routes.watchScreen, args: val);
                            } else {
                              CommonFunctions().showLoginDialog(context);
                            }
                          },
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1000),
                        autoPlayCurve: Curves.easeInOut,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
                  )
                : Container(),
            // Netflix-style gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height:25.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
            // Netflix-style content overlay
            if (data.homeBanner.isNotEmpty)
              Positioned(
                bottom: 3.h,
                left: 6.w,
                right: 6.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      data.homeBanner[_current].title ?? "Featured Content",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    // Description or genre
                    Text(
                      data.homeBanner[_current].description ??
                          "Popular on NIRI9",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    // Action buttons row
                    Row(
                      children: [
                        // Play button
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              if (Storage.instance.isLoggedIn) {
                                Navigation.instance.navigate(Routes.watchScreen,
                                    args: data.homeBanner[_current].id);
                              } else {
                                CommonFunctions().showLoginDialog(context);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Play',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        // My List button
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              if (Storage.instance.isLoggedIn) {
                                addToMyList(data.homeBanner[_current].id);
                              } else {
                                Navigation.instance
                                    .navigate(Routes.loginScreen, args: "");
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'My List',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // Share button
                        GestureDetector(
                          onTap: () {
                            Share.share(
                                'check out NIRI9 from https://play.google.com/store/apps/details?id=com.niri.niri9');
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                        if (data.homeBanner[_current].hasRent ?? false) ...[
                          SizedBox(width: 3.w),
                          Container(
                            padding: EdgeInsets.all(1.h),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.shop,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            // Dots indicator at bottom
            if (data.homeBanner.isNotEmpty && data.homeBanner.length > 1)
              Positioned(
                bottom: 1.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.homeBanner.asMap().entries.map((entry) {
                    return Container(
                      width: _current == entry.key ? 8.0 : 6.0,
                      height: _current == entry.key ? 8.0 : 6.0,
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> addToMyList(int? id) async {
    final response = await ApiProvider.instance.addMyVideos(id);
    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Added To My List");
      widget.fetchData();
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
    }
  }
}

class BannerImageItem extends StatelessWidget {
  const BannerImageItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final BannerResult item;
  final Function(int?) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.h,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: item.posterPic ?? "",
        fit: BoxFit.cover,
        height: 55.h,
        width: double.infinity,
        placeholder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                Assets.logoTransparent,
                opacity: const AlwaysStoppedAnimation(0.3),
                width: 20.w,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 12.w,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
