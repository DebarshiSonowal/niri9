import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Functions/Trending/Widgets/trending_section.dart';
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
