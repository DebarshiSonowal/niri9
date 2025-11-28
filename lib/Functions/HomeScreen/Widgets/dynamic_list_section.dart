import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Models/sections.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../LanguageSelectedPage/language_selected_page.dart';
import 'dynamic_list_item.dart';

class DynamicListSectionHome extends StatefulWidget {
  const DynamicListSectionHome({super.key});

  @override
  State<DynamicListSectionHome> createState() => _DynamicListSectionHomeState();
}

class _DynamicListSectionHomeState extends State<DynamicListSectionHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sections>>(
      future: _fetchSections(context),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _fadeController.forward();
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<Repository>(
              builder: (context, data, _) {
                final sections = data.homeSections;
                if (sections.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: EdgeInsets.only(top: 1.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sections.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 1.5.h),
                    itemBuilder: (context, index) {
                      final item = sections[index];
                      if (item.videos?.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200 + (index * 50)),
                        curve: Curves.easeOutCubic,
                        child: DynamicListItem(
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
                  ),
                );
              },
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Container(
            height: 35.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Card(
              elevation: 0,
              color: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 48,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Text(
                      'No content available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Check back later for new content',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 30.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Card(
              elevation: 0,
              color: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.withOpacity(0.7),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextButton(
                      onPressed: () => setState(() {}),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Loading state with enhanced shimmer
        return Container(
          margin: EdgeInsets.only(top: 1.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: const ShimmerLanguageScreen(),
          ),
        );
      },
    );
  }

  Future<List<Sections>> _fetchSections(BuildContext context) async {
    try {
      debugPrint("DynamicListSectionHome: Fetching sections for 'home' page");

      final response = await ApiProvider.instance.getSections("home", '1', '');

      if (response.status ?? false) {
        if (mounted) {
          Provider.of<Repository>(context, listen: false)
              .addHomeSections(response.sections ?? []);
        }
        return response.sections ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("DynamicListSectionHome: Error fetching sections: $e");
      rethrow; // This will trigger the error state in FutureBuilder
    }
  }
}
