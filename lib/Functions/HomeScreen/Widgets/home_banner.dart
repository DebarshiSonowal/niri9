import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:niri9/Constants/assets.dart';
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
import 'my_list_button.dart';
import 'share_indicator.dart';
import 'slider_indicator.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({Key? key}) : super(key: key);

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
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: Consumer<Repository>(builder: (context, data, _) {
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
                        // enlargeCenterPage: true,
                        aspectRatio: 10 / 9,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          debugPrint(
                              "onPageChanged $index ${data.homeBanner[_current].hasMyList}");
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
                          hasMyList:
                              data.homeBanner[_current].hasMyList ?? false,
                          onTap: () {
                            addToMyList(data.homeBanner[_current].id);
                          },
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
                            // showSuccessDialog(context: context);
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
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
            // color: Colors.grey,
            width: double.infinity,

            padding: EdgeInsets.only(
              bottom: 0.7.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15.w,
                ),
                GestureDetector(
                  onTap: () => onTap(item.id),
                  child: const PlayNowButton(),
                ),
                SizedBox(
                  width: 15.w,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: (item.hasRent ?? false)
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shop,
                                color: Colors.yellow,
                              )
                            ],
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
