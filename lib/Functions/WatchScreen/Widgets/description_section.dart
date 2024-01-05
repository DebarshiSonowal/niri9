import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        padding: EdgeInsets.only(
          left: 5.w,
          right: 5.w,
          bottom: 0.5.h,
          top: 1.5.h,
        ),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Audio Language",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 9.sp,
                      ),
                ),
                SizedBox(
                  width: 4.w,
                ),
                GestureDetector(
                  onTap: () {
                    if (data.videoDetails!.related_language.isNotEmpty) {
                      showLanguages(context, data);
                    } else {
                      Fluttertoast.showToast(
                          msg: "Only one language is available");
                    }
                  },
                  child: Text(
                    "${data.videoDetails?.language_name}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Constants.thirdColor,
                          fontSize: 9.sp,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  "Available in ${(data.videoDetails?.related_language.length ?? 0) + 1} language",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white30,
                        fontSize: 9.sp,
                      ),
                ),
                SizedBox(
                  width: 1.w,
                ),
              ],
            ),
            SizedBox(
              height: 1.5.h,
            ),
            ReadMoreText(
              data.videoDetails?.description ??
                  'What would you give to turn back time? A yong passionate group of boxers being trained by a renowned retired boxer,'
                      'living their perfect little lives until one day everything startst of a deawa ',
              numLines: 2,
              readMoreText: '',
              readLessText: '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white30,
                    fontSize: 9.sp,
                  ),
              readMoreTextStyle:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Constants.thirdColor,
                        fontSize: 9.sp,
                      ),
              readMoreIcon: const Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Constants.thirdColor,
              ),
              readLessIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Constants.thirdColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  void showLanguages(context, Repository data) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Select Audio Language From Below\n",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i in data.videoDetails!.related_language)
                    ListTile(
                      onTap: () {
                        Navigation.instance.navigateAndReplace(
                            Routes.watchScreen,
                            args: i.video_id);
                      },
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0.2.h,
                      ),
                      title: Text(
                        i.language_name ?? "",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
