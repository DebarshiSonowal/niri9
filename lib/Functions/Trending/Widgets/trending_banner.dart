import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Functions/Trending/Widgets/trending_slider_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/banner.dart';
import '../../../Models/sections.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../HomeScreen/Widgets/my_list_button.dart';
import '../../HomeScreen/Widgets/share_indicator.dart';
import '../../HomeScreen/Widgets/slider_indicator.dart';
import 'trending_banner_item.dart';

class TrendingBanner extends StatefulWidget {
  const TrendingBanner({Key? key}) : super(key: key);

  @override
  State<TrendingBanner> createState() => _TrendingBannerState();
}

class _TrendingBannerState extends State<TrendingBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, _) {
        if (_.hasData && (_.data != null)) {
          return const TrendingBannerSection();
        }
        if (_.hasData && (_.data == null)) {
          return Container();
        }
        return Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.white70,
          child: Container(
            width: double.infinity,
            height: 40.h,
            color: Colors.white30,
          ),
        );
      },
      future: getData(context),
    );
  }

  Future<List<BannerResult>> getData(context) async {
    final response = await ApiProvider.instance.getBannerResponse("home");
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .addTrendingBanner(response.result ?? []);
      // await fetchVideos(response.sections[0]);
      return response.result ?? [];
    } else {
      return List<BannerResult>.empty();
    }
  }
}

class TrendingBannerSection extends StatefulWidget {
  const TrendingBannerSection({super.key});

  @override
  State<TrendingBannerSection> createState() => _TrendingBannerSectionState();
}

class _TrendingBannerSectionState extends State<TrendingBannerSection> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return SizedBox(
        width: double.infinity,
        height: 40.h,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            data.trendingBanner.isNotEmpty
                ? SizedBox(
                    height: 40.h,
                    width: double.infinity,
                    child: CarouselSlider.builder(
                      // itemCount: data.bannerList.length,
                      itemCount: data.trendingBanner.length,
                      itemBuilder:
                          (BuildContext context, int index, int realIndex) {
                        var item = data.trendingBanner[index];
                        return TrendingBannerItem(item: item);
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        // enlargeCenterPage: true,
                        aspectRatio: 10.5 / 9,
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
            data.trendingBanner.isNotEmpty
                ? Container(
                    margin: EdgeInsets.only(
                      bottom: 1.h,
                    ),
                    width: double.infinity,
                    height: 5.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyListButton(
                          hasMyList:
                              data.homeBanner[_current].hasMyList ?? false,
                          onTap: () {
                            addToMyList(data.homeBanner[_current].id);
                          },
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        TrendingSliderIndicator(current: _current),
                        SizedBox(
                          width: 3.w,
                        ),
                        ShareIndicator(
                          onTap: () {
                            Share.share("Check out our app on Play Store https://play.google.com/store/apps/details?id=com.niri.niri9}");
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      );
    });
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

class PlayNowButton extends StatelessWidget {
  const PlayNowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.h,
      ),
      child: Center(
        child: Text(
          "Play Now",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
