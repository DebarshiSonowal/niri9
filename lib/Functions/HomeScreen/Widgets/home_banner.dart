import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Models/banner.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import 'my_list_button.dart';
import 'share_indicator.dart';
import 'slider_indicator.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({Key? key}) : super(key: key);

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchBanner(context),
        builder: (context, _) {
          if (_.hasData && (_.data ?? false) == true) {
            return const BannerSection();
          }
          if (_.hasData && (_.data ?? false) == false) {
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
  const BannerSection({super.key});
  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _current=0;
  final CarouselController controller = CarouselController();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: Consumer<Repository>(
        builder: (context,data,_) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              data.homeBanner.isNotEmpty
                  ? SizedBox(
                height: 40.h,
                width: double.infinity,
                child: CarouselSlider.builder(
                  carouselController: controller,
                  // itemCount: data.bannerList.length,
                  itemCount: data.homeBanner.length,
                  itemBuilder: (BuildContext context, int index,
                      int realIndex) {
                    var item = data.homeBanner[index];
                    return BannerImageItem(
                      item: item,
                      onTap: (int? val) {
                        Navigation.instance.navigate(
                            Routes.watchScreen,
                            args: val);
                      },
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    // enlargeCenterPage: true,
                    aspectRatio: 10 / 9,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      debugPrint("onPageChanged $index");
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
              )
                  : Container(),
              data.homeBanner.isNotEmpty
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
                      onTap: () {},
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    SliderIndicator(current: _current),
                    SizedBox(
                      width: 3.w,
                    ),
                    ShareIndicator(
                      onTap: () {
                        Share.share(
                            'check out NIRI9 from https://play.google.com/store/apps/details?id=com.niri.niri9');
                      },
                    ),
                  ],
                ),
              )
                  : Container(),
            ],
          );
        }
      ),
    );
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
    return GestureDetector(
      onTap: () => onTap(item.id),
      child: SizedBox(
        height: 40.h,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CachedNetworkImage(
              imageUrl: item.posterPic ?? "",
              fit: BoxFit.fill,
              height: 40.h,
              width: double.infinity,
              placeholder: (context, index) {
                return Image.asset(
                  Assets.logoTransparent,
                );
              },
            ),
            Container(
              height: 7.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
              // color: Colors.grey,
              width: double.infinity,

              padding: EdgeInsets.only(
                bottom: 0.7.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30.w,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
