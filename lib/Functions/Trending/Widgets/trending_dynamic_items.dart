import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Models/sections.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../LanguageSelectedPage/language_selected_page.dart';
import 'dynamic_premium_list_item.dart';

class TrendingDynamicItems extends StatefulWidget {
  const TrendingDynamicItems({
    super.key,
    required this.page,
    required this.selectedCategory,
  });

  final int page;
  final String selectedCategory;

  @override
  State<TrendingDynamicItems> createState() => _TrendingDynamicItemsState();
}

class _TrendingDynamicItemsState extends State<TrendingDynamicItems> {


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, _) {
        if (_.hasData && (_.data != [])) {
          return Consumer<Repository>(builder: (context, data, _) {
            // Filter sections based on selected category
            var filteredSections = data.trendingSections;
            if (widget.selectedCategory != 'All') {
              filteredSections = data.trendingSections
                  .where((section) =>
                      section.title
                          ?.toLowerCase()
                          .contains(widget.selectedCategory.toLowerCase()) ??
                      false)
                  .toList();
            }

            return Container(
              color: Colors.black,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                itemBuilder: (context, index) {
                  var item = filteredSections[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    child: DynamicPremiumListItem(
                      text: item.title ?? "",
                      list: item.videos ?? [],
                      onTap: () {
                        Navigation.instance.navigate(
                          Routes.moreScreen,
                          args: item.title ?? "",
                        );
                      },
                    ),
                  );
                },
                itemCount: filteredSections.length,
              ),
            );
          });
        }
        if (_.hasData && (_.data == [])) {
          return Container(
            height: 30.h,
            color: Colors.black,
            child: Center(
              child: Text(
                'No content available for this category',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                ),
              ),
            ),
          );
        }
        return Container(
          color: Colors.black,
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: const ShimmerLanguageScreen(),
          ),
        );
      },
      future: fetchDetails(context, widget.page),
    );
  }

  Future<List<Sections>> fetchDetails(context, page) async {
    final response1 =
        await ApiProvider.instance.getSections("trending", "$page", '');
    if (response1.status ?? false) {
      Provider.of<Repository>(context, listen: false)
          .addTrendingSections(response1.sections ?? []);
      return response1.sections ?? [];
    } else {
      return List<Sections>.empty();
    }
  }
}