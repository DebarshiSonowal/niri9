import 'package:flutter/material.dart';
import 'package:niri9/Models/available_language.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import 'language_item.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({
    super.key, required this.scrollController,
  });
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        width: double.infinity,
        height: 11.h,
        child: ListView.separated(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var item = data.languages[index];
            return LanguageItem(
              item: item,
              onTap: () {
                Navigation.instance
                    .navigate(Routes.selectedLanguageScreen, args: item.slug);
              },
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 2.w,
            );
          },
          itemCount: data.languageList.length,
        ),
      );
    });
  }
}


