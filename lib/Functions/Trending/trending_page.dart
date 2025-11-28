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
import 'Widgets/trending_hero_section.dart';
import 'Widgets/trending_categories.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  bool isEnd = false;
  int page = 1;
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Movies',
    'TV Shows',
    'Documentaries',
    'Comedy',
    'Drama',
    'Action',
    'Horror',
    'Romance'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Clean Netflix-style app bar
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            floating: false,
            snap: false,
            toolbarHeight: 8.h,
            leading: Container(
              margin: EdgeInsets.only(left: 4.w),
              child: IconButton(
                onPressed: () {
                  Navigation.instance.goBack();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 6.w,
                ),
                splashRadius: 24,
              ),
            ),
            title: Container(
              child: Text(
                "Trending",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            centerTitle: false,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 2.w),
                child: IconButton(
                  onPressed: () {
                    // Add search functionality
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 6.w,
                  ),
                  splashRadius: 24,
                ),
              ),

            ],
          ),

          // Hero trending section
          SliverToBoxAdapter(
            child: TrendingHeroSection(),
          ),

          // Category selector
          SliverToBoxAdapter(
            child: TrendingCategories(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          ),

          // Trending sections
          SliverToBoxAdapter( 
            child: Container(
              color: Colors.black,
              child: TrendingDynamicItems(
                  page: page, selectedCategory: selectedCategory),
            ),
          ),

          // Extra bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.premiumScreen);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure correct navigation index when coming back to trending screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.premiumScreen);
    });
  }
}
