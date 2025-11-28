import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../Services/update_service.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/title_box.dart';
import 'Widgets/custom_app_bar.dart';
import 'Widgets/dynamic_list_section.dart';
import 'Widgets/home_banner.dart';
import 'Widgets/language_section.dart';
import 'Widgets/recently_viewed_section.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool isExpanded = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isScrolled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHomeScreen();
      _slideController.forward();
      UpdateService().checkForUpdates(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure correct navigation index when coming back to home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.homeScreen);
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  void _initializeHomeScreen() {
    final repository = Provider.of<Repository>(context, listen: false);
    CustomBottomNavBar.ensureCorrectIndex(context, Routes.homeScreen);
    _fetchRecentlyViewed(1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isExpanded ? 12.h : 24.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: CustomAppbar(
            isExpanded: isExpanded,
            updateState: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Constants.primaryColor,
                Constants.primaryColor.withOpacity(0.95),
                Constants.primaryColor,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Banner Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    child: const HomeBanner(),
                  ),
                ),

                // Language Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.w),
                          child: TitleBox(
                            text: "Explore in your language",
                            onTap: () {},
                            isEnd: false,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 1.h, bottom: 1.5.h),
                          child: LanguageSection(
                            scrollController: _scrollController,
                            onScroll: (UserScrollNotification notification) {
                              // Handle scroll notifications if needed
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recently Viewed Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    child: const RecentlyViewedSection(),
                  ),
                ),

                // Dynamic Sections
                const SliverToBoxAdapter(
                  child: DynamicListSectionHome(),
                ),

                // Bottom spacing
                SliverToBoxAdapter(
                  child: SizedBox(height: 3.h),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: const CustomBottomNavBar(),
      ),
    );
  }

  Future<void> _fetchRecentlyViewed(int pageNo) async {
    try {
      final response = await ApiProvider.instance.getRecentlyVideos(pageNo);
      if (response.success ?? false && mounted) {
        Provider.of<Repository>(context, listen: false)
            .setRecentlyViewedVideos(response.videos ?? []);
      }
    } catch (e) {
      debugPrint("Failed to fetch recently viewed videos: $e");
    }
  }
}
