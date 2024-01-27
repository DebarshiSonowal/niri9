import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lists/flutter_lists.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/rent_bottom_sheet.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/assets.dart';
import '../../../Constants/constants.dart';
import 'icon_text_button.dart';

class OptionsBar extends StatelessWidget {
  const OptionsBar({
    super.key,
    required this.customVideoPlayerController,
  });

  final CustomVideoPlayerController customVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white54,
              width: 0.03.h,
            ),
            bottom: BorderSide(
              color: Colors.white54,
              width: 0.03.h,
            ),
          ),
        ),
        height: 10.h,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 1.h,
                ),
                color: const Color(0xff2a2829),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTextButton(
                      name: "Share",
                      icon: Icons.share,
                      onTap: () {
                        Share.share("Check out our app on Play Store https://play.google.com/store/apps/details?id=com.niri.niri9}");
                      },
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    IconTextButton(
                      name: "My List",
                      icon: Icons.playlist_add,
                      onTap: () {
                        addToMyList(data.videoDetails?.id);
                      },
                    ),
                    (data.videoDetails?.has_rent ?? false)?SizedBox(
                      width: 5.w,
                    ):Container(),
                    (data.videoDetails?.has_rent ?? false)?IconTextButton(
                      name: "Rent",
                      icon: Icons.money,
                      onTap: () {
                        if (data.videoDetails?.has_rent ?? false) {
                          showRenting(context,data.videoDetails);
                        }
                      },
                    ):Container(),
                  ],
                ),
              ),
            ),
            data.videoDetails?.trailer_player!=""?Expanded(
              flex: 2,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    // _launchUrl(data.videoDetails?.trailer_player ?? "");
                    await customVideoPlayerController.videoPlayerController
                        .pause();
                    await showTrailer(
                        data.videoDetails?.trailer_player ?? "", context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: Constants.thirdColor,
                        size: 22.sp,
                      ),
                      SizedBox(
                        height: 1.2.h,
                      ),
                      Text(
                        "Watch Trailer",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ):Container(),
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

  Future<void> _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  void showRenting(context, Video? videoDetails) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      // context and builder are
      // required properties in this widget
      isDismissible:true,
      context: context,
      builder: (BuildContext context) {
        // we set up a container inside which
        // we create center column and display text

        // Returning SizedBox instead of a Container
        return RentBottomSheet(videoDetails:videoDetails);
      },
    );
  }

  Future<bool> showTrailer(String url, BuildContext context) async {
    final resp = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: TrailerWidget(
            url: url,
          ),
        );
      },
    ).then((value) {
      return false;
    });
    return true;
  }
}

class TrailerWidget extends StatefulWidget {
  const TrailerWidget({super.key, required this.url});

  final String url;

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  late CustomVideoPlayerController _customVideoPlayerController;
  late VideoPlayerController videoPlayerController;
  Future<bool>? _future;

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      // initiateVideoPlayer(context);
      setState(() {
        _future = initiateVideoPlayer(context, widget.url);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 20.h,
      color: Colors.black,
      child: FutureBuilder(
          future: _future,
          builder: (context, _) {
            if (_.hasData) {
              return CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController,
              );
            }
            if (_.hasError) {
              return const Center(
                child: Text("Something went wrong"),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }),
    );
  }

  Future<bool> initiateVideoPlayer(context, url) async {
    debugPrint(url);
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(url ?? Assets.videoUrl));
    await videoPlayerController.initialize();

    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
          playOnlyOnce: true,
          // customVideoPlayerPopupSettings: ,
        ));
    videoPlayerController.play();
    return true;
  }
}

class RentalBodyWidget extends StatelessWidget {
  const RentalBodyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.5.h,
      ),
      height: 70.h,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Illegal",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Text(
              "Web Series . 10-Dec-2023 . Session 1",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    // fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
              width: double.infinity,
              height: 11.h,
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffe6e6e6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Validity",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                      Text(
                        "15 days",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 0.8.h,
                    color: Colors.black,
                  ),
                  Text(
                    "You have 15 days to start watching this content once retired",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          // fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
              width: double.infinity,
              height: 11.h,
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffe6e6e6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Watch Time",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                      Text(
                        "50 hours",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 0.8.h,
                    color: Colors.black,
                  ),
                  Text(
                    "You have 15 days to start watching this content once retired",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          // fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            SizedBox(
              height: 25.h,
              width: double.infinity,
              child: Theme(
                data: ThemeData(
                  textTheme: Theme.of(context).textTheme.apply(
                        bodyColor: Colors.black87,
                        fontSizeFactor: 2.5,
                      ),
                ),
                child: const UnorderedList<String>(
                  items: [
                    "You can watch this content multiple times during the 50 hours period",
                    "This is a non-refundable transaction",
                    "This content is only available for rent and not a part of Premium Subscription",
                    "You can play your content on this device/ Niri9 Account only"
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
              width: double.infinity,
              height: 11.h,
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffe6e6e6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      "By renting you agree to our Terms of Service",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            // fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 20.w,
                    height: 4.h,
                    child: Center(
                      child: Text(
                        "Rent for ₹59",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
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
