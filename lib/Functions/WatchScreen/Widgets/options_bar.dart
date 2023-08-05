import 'package:flutter/material.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Constants/constants.dart';
import 'icon_text_button.dart';

class OptionsBar extends StatelessWidget {
  const OptionsBar({
    super.key,
  });

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
                  children: [
                    IconTextButton(
                      name: "Share",
                      icon: Icons.share,
                      onTap: () {},
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    IconTextButton(
                      name: "Watchlist",
                      icon: Icons.playlist_add,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _launchUrl(data.videoDetails?.trailer_player??"");
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
            ),
          ],
        ),
      );
    });
  }
  Future<void> _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }
}
