import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Models/sections.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/category_specific_appbar.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class LanguageSelectedPage extends StatefulWidget {
  const LanguageSelectedPage({super.key, required this.language});

  final String language;

  @override
  State<LanguageSelectedPage> createState() => _LanguageSelectedPageState();
}

class _LanguageSelectedPageState extends State<LanguageSelectedPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefresh();
    });
  }

  void _onRefresh() async {
    debugPrint("🔄 _onRefresh called");
    if (_isLoading) {
      debugPrint("⚠️ Already loading, skipping refresh");
      return;
    }

    debugPrint("🔄 Starting refresh...");
    setState(() {
      _isLoading = true;
      page = 1;
    });

    debugPrint("🗑️ Clearing existing language sections");
    Provider.of<Repository>(context, listen: false).addLanguageSections([]);

    try {
      debugPrint("📡 Fetching page 1 data...");
      await fetchVideos(context);
      debugPrint("✅ Refresh completed successfully");
      _refreshController.refreshCompleted();
    } catch (e) {
      debugPrint("❌ Refresh failed: $e");
      _refreshController.refreshFailed();
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint("🔄 Refresh process ended");
    }
  }

  void _onLoading() async {
    debugPrint("⬆️ _onLoading called (pull to load more)");
    if (_isLoading) {
      debugPrint("⚠️ Already loading, skipping load more");
      return;
    }

    debugPrint("⬆️ Starting load more...");
    debugPrint("📍 Current page: $page, incrementing to: ${page + 1}");

    setState(() {
      _isLoading = true;
      page++;
    });

    try {
      debugPrint("📡 Fetching page $page data...");
      final hasMoreData = await fetchVideos(context);
      debugPrint("📊 Has more data: $hasMoreData");

      if (hasMoreData) {
        debugPrint("✅ Load more completed - more data available");
        _refreshController.loadComplete();
      } else {
        debugPrint("🏁 Load more completed - no more data");
        _refreshController.loadNoData();
      }
    } catch (e) {
      setState(() {
        page--; // Revert page increment on error
      });
      _refreshController.loadFailed();
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint("⬆️ Load more process ended");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(7.h),
          child: CategorySpecificAppbar(
              searchTerm: widget.language.split(",")[1])),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        child: Consumer<Repository>(builder: (context, data, _) {
          // Show shimmer on initial load
          if (data.languageSections.isEmpty && _isLoading) {
            return const ShimmerLanguageScreen();
          }

          // Show no data message
          if (data.languageSections.isEmpty && !_isLoading) {
            return Center(
              child: Text(
                "No Videos Available",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
              ),
            );
          }

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = const Text("pull up load",
                      style: TextStyle(color: Colors.white));
                } else if (mode == LoadStatus.loading) {
                  body = const CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = const Text("Load Failed! Click retry!",
                      style: TextStyle(color: Colors.white));
                } else if (mode == LoadStatus.canLoading) {
                  body = const Text("release to load more",
                      style: TextStyle(color: Colors.white));
                } else {
                  body = const Text("No more Data",
                      style: TextStyle(color: Colors.white));
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var item = data.languageSections[index];
                return DynamicListItem(
                  text: item.title ?? "",
                  list: item.videos ?? [],
                  onTap: () {
                    Navigation.instance
                        .navigate(Routes.moreScreen, args: item.title ?? "");
                  },
                );
              },
              itemCount: data.languageSections.length,
            ),
          );
        }),
      ),
    );
  }

  Future<bool> fetchVideos(context) async {
    final languageId = widget.language.split(",")[0];
    final languageName = widget.language.split(",")[1];

    debugPrint(" LanguageSelectedPage: Starting fetchVideos");
    debugPrint(" Page: $page");
    debugPrint(" Language ID: $languageId");
    debugPrint(" Language Name: $languageName");

    try {
      debugPrint(" Making API call to getSections...");
      final response = await ApiProvider.instance
          .getSections("language", "$page", languageId);

      debugPrint(" API Response received");
      debugPrint(" Success: ${response.status}");
      debugPrint(" Sections count: ${response.sections?.length ?? 0}");

      if (response.status ?? false) {
        final sections = response.sections ?? [];
        final repo = Provider.of<Repository>(context, listen: false);

        debugPrint(" Processing ${sections.length} sections for page $page");

        // Log each section details
        for (int i = 0; i < sections.length; i++) {
          final section = sections[i];
          debugPrint(
              "  Section $i: '${section.title}' - ${section.videos?.length ?? 0} videos");
        }

        if (page == 1) {
          debugPrint(" First page - replacing all data");
          repo.addLanguageSections(sections);
        } else {
          debugPrint(" Loading more - page $page");

          final existingSections = repo.languageSections;
          final existingTitles = existingSections.map((s) => s.title).toSet();

          debugPrint(" Existing sections: ${existingSections.length}");
          debugPrint(" Existing titles: ${existingTitles.toList()}");

          final newSections = sections
              .where((section) => !existingTitles.contains(section.title))
              .toList();

          debugPrint(" New unique sections: ${newSections.length}");
          for (int i = 0; i < newSections.length; i++) {
            debugPrint("  New section: '${newSections[i].title}'");
          }

          final combinedSections = [...existingSections, ...newSections];
          repo.addLanguageSections(combinedSections);

          debugPrint(" Total sections after merge: ${combinedSections.length}");

          if (newSections.isEmpty) {
            debugPrint(" No new sections found - end of data");
          }

          return newSections.isNotEmpty;
        }

        debugPrint(" fetchVideos completed successfully");
        return sections.isNotEmpty;
      } else {
        debugPrint(" API returned success=false");
        debugPrint(" Message: ${response.message ?? 'No message'}");
        return false;
      }
    } catch (e) {
      debugPrint(" Error in fetchVideos: $e");
      debugPrint(" Page when error occurred: $page");
      debugPrint(" Language: $languageName ($languageId)");
      return false;
    }
  }
}

class ShimmerLanguageScreen extends StatelessWidget {
  const ShimmerLanguageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 2.h,
      ),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white70,
              child: Container(
                color: Colors.white30,
                width: 20.w,
                height: 2.h,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              width: double.infinity,
              height: 25.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Container(
                      height: 20.h,
                      width: 40.w,
                      color: Colors.white30,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 2.h,
                  );
                },
                itemCount: 4,
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white70,
              child: Container(
                color: Colors.white30,
                width: 20.w,
                height: 2.h,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              width: double.infinity,
              height: 25.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Container(
                      height: 20.h,
                      width: 40.w,
                      color: Colors.white30,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 2.h,
                  );
                },
                itemCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


