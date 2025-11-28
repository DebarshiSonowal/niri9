// import 'package:appinio_video_player/appinio_video_player.dart';
// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/rent_bottom_sheet.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
// import 'package:video_player/video_player.dart';

import '../../../API/api_provider.dart';

class OptionsBar extends StatelessWidget {
  const OptionsBar({super.key, required this.onEpisodeTap});

  final Function(String) onEpisodeTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      final hasRent = data.videoDetails?.has_rent ?? false;
      final hasSubscription = data.user?.has_subscription ?? false;
      final trailerPlayer = data.videoDetails?.trailer_player ?? "";

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff1a1a1a).withOpacity(0.95),
              const Color(0xff0a0a0a).withOpacity(0.98),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: trailerPlayer.isNotEmpty ? 3 : 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.share_rounded,
                      label: "Share",
                      onTap: () {
                        Share.share(
                            "Check out Niri 9 - Movies & Web Series App!\n\n📱 iOS: https://apps.apple.com/in/app/niri-9-movies-web-series-app/id1548207144\n🤖 Android: https://play.google.com/store/apps/details?id=com.niri.niri9");
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.bookmark_add_outlined,
                      label: "My List",
                      onTap: () {
                        addToMyList(data.videoDetails?.id);
                      },
                    ),
                  ],
                ),
              ),
              if (trailerPlayer.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: _buildTrailerButton(context, trailerPlayer),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xff2a2a2a).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 22.sp,
              ),
              SizedBox(height: 0.8.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailerButton(BuildContext context, String trailerUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEpisodeTap(trailerUrl),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xffe50914),
                const Color(0xffc5050f),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffe50914).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  "Watch Trailer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addToMyList(int? id) async {
    final response = await ApiProvider.instance.addMyVideos(id);
    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Added To My List");
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
    }
  }

  Future<void> showRenting(BuildContext context, Video? videoDetails) async {
    return showModalBottomSheet(
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      context: context,
      builder: (_) => RentBottomSheet(videoDetails: videoDetails),
    );
  }
}
