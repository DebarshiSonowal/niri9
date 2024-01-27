import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Functions/Trending/Widgets/trending_banner.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/constants.dart';
import '../../Models/sections.dart';
import '../../Navigation/Navigate.dart';
import '../../Router/routes.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import '../HomeScreen/Widgets/home_banner.dart';
import '../LanguageSelectedPage/language_selected_page.dart';
import 'Widgets/dynamic_premium_list_item.dart';
import 'Widgets/dynamic_premium_other_list_item.dart';
import 'Widgets/trending_dynamic_items.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  bool isEnd = false;
  int page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trending",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                // fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        color: Constants.primaryColor,
        height: 100.h,
        width: 100.w,
        padding: EdgeInsets.symmetric(
          vertical: 0.5.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TrendingBanner(),
              SizedBox(
                height: 0.5.h,
              ),
              TrendingDynamicItems(page: page),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () => {
    // fetchDetails()
    // });
    Future.delayed(Duration.zero, () {
      // fetchData(context);
      Provider.of<Repository>(context,listen: false).updateIndex(2);
    });
  }
}





