import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/Search/Widgets/genre_select_button.dart';
import 'package:niri9/Models/genres.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/common_functions.dart';
import '../../Helper/storage.dart';
import '../../Models/category.dart';
import '../../Models/sections.dart';
import '../../Repository/repository.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/category_specific_appbar.dart';
import '../HomeScreen/Widgets/ott_item.dart';
import 'Widgets/category_select_button.dart';
import 'Widgets/search_app_bar.dart';
import 'Widgets/section_select_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.filters});

  final String? filters;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Genres? selectedGenre;
  Sections? selectedSections;
  Category? selectedCategory;
  int page_no = 1;
  String currentSearch = "";
  final searchEditingController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.searchScreen);

      final repository = Provider.of<Repository>(context, listen: false);

      if (repository.genres.isNotEmpty) {
        selectedGenre = repository.genres[0];
      }

      // Don't auto-select the first category - let "All" be default
      if (widget.filters != null && widget.filters!.isNotEmpty) {
        if (repository.categories.isNotEmpty) {
          try {
            selectedCategory = repository.categories
                .firstWhere((element) => element.name == widget.filters);
          } catch (e) {
            debugPrint("Category not found: ${widget.filters}");
          }
        }
      }

      if (repository.homeSections.isNotEmpty) {
        selectedSections = repository.homeSections[0];
      }

      setState(() {});

      // Load initial content
      search("");
    });

    searchEditingController.addListener(() {
      setState(() {
        currentSearch = searchEditingController.text;
      });
    });

    searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure correct navigation index is maintained
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.searchScreen);
    });
  }

  @override
  void dispose() {
    searchEditingController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      body: Column(
        children: [
          const CategorySpecificAppbar(searchTerm: "Search"),
          Expanded(
            child: Container(
              color: Constants.backgroundColor,
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: currentSearch.isEmpty
                        ? _buildPopularContent()
                        : _buildSearchResults(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Constants.secondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: searchEditingController,
          focusNode: searchFocusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search movies, shows...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
            suffixIcon: searchFocusNode.hasFocus && currentSearch.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      searchEditingController.clear();
                      searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              suggest(value);
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              search(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPopularContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoriesSection(),
          SizedBox(height: 3.h),
          _buildPopularSearchesSection(),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<Repository>(
      builder: (context, data, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              _buildCategoryPills(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryPills(Repository data) {
    // Create a combined list with "All" first, then API categories
    final List<Map<String, dynamic>> allCategories = [
      {
        'id': -1,
        'name': 'All',
        'icon': Icons.grid_view_rounded,
        'selected': selectedCategory == null,
      },
    ];

    // Add API categories
    allCategories.addAll(
      data.categories
          .map((category) => {
                'id': category.id,
                'name': category.name,
                'icon': _getCategoryIcon(category.name ?? ''),
                'selected': selectedCategory?.id == category.id,
                'category': category,
              })
          .toList(),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: allCategories.map((categoryData) {
        final isSelected = categoryData['selected'] as bool;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (categoryData['id'] == -1) {
                // "All" selected
                selectedCategory = null;
              } else {
                selectedCategory = categoryData['category'] as Category;
              }
            });
            // Trigger search with new category
            search(currentSearch);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Constants.thirdColor : Constants.secondaryColor,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Constants.primaryColor,
                      width: 1,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  categoryData['icon'] as IconData,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  categoryData['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('movie')) return Icons.movie_rounded;
    if (name.contains('series') || name.contains('web'))
      return Icons.tv_rounded;
    if (name.contains('action')) return Icons.bolt_rounded;
    if (name.contains('comedy')) return Icons.sentiment_very_satisfied_rounded;
    if (name.contains('drama')) return Icons.favorite_rounded;
    if (name.contains('horror')) return Icons.nights_stay_rounded;
    if (name.contains('thriller')) return Icons.flash_on_rounded;
    if (name.contains('romance')) return Icons.favorite_border_rounded;
    if (name.contains('documentary')) return Icons.videocam_rounded;
    if (name.contains('animation')) return Icons.animation_rounded;
    return Icons.category_rounded;
  }

  Widget _buildPopularSearchesSection() {
    return Consumer<Repository>(
      builder: (context, data, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Top Searches",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Constants.thirdColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TRENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              if (data.specificVideos.isNotEmpty) ...[
                _buildBannerCard(data.specificVideos[0]),
                SizedBox(height: 2.h),
                _buildRankedList(data.specificVideos.skip(1).take(10).toList()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.watchScreen, args: item.id);
        } else {
          CommonFunctions().showLoginDialog(context);
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Constants.secondaryColor,
          image: item.profile_pic != null && item.profile_pic!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(item.profile_pic!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Constants.thirdColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '#1 POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(8.0 + (item.id ?? 0) % 20 / 10).toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.genres.isNotEmpty
                            ? item.genres.first.name ?? 'Drama'
                            : 'Drama',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankedList(List<dynamic> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (Storage.instance.isLoggedIn) {
              Navigation.instance.navigate(Routes.watchScreen, args: item.id);
            } else {
              CommonFunctions().showLoginDialog(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Constants.thirdColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 2}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.primaryColor,
                    image:
                        item.profile_pic != null && item.profile_pic!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(item.profile_pic!),
                                fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.genres.isNotEmpty
                            ? item.genres.first.name ?? 'Drama'
                            : 'Drama',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(7.5 + (item.id ?? 0) % 15 / 10).toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${2020 + (item.id ?? 0) % 5}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<Repository>(
      builder: (context, data, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            itemCount: data.specificVideos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (BuildContext context, int index) {
              var item = data.specificVideos[index];
              return OttItem(
                item: item,
                onTap: () {
                  if (Storage.instance.isLoggedIn) {
                    Navigation.instance
                        .navigate(Routes.watchScreen, args: item.id);
                  } else {
                    CommonFunctions().showLoginDialog(context);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  void search(String search) async {
    Navigation.instance.navigate(Routes.loadingScreen);

    try {
      VideoResponse response;

      if (selectedCategory != null) {
        // Use getVideos API with category filter when a category is selected
        response = await ApiProvider.instance.getVideos(
          1,
          // page_no
          null,
          // language
          selectedCategory!.slug,
          // category slug
          null,
          // genre
          search.isEmpty ? null : search,
          // search term
          "search",
          // page type
          null, // type
        );
      } else {
        // Use regular search API when no category filter
        if (search.isEmpty) {
          // For empty search, get all videos
          response = await ApiProvider.instance.getVideos(
            1,
            // page_no
            null,
            // language
            null,
            // category
            null,
            // genre
            null,
            // search
            "search",
            // page type
            null, // type
          );
        } else {
          response = await ApiProvider.instance.search(search);
        }
      }

      Navigation.instance.goBack();

      if (response.success ?? false) {
        debugPrint(
            "Search ${response.videos.length} results for category: ${selectedCategory?.name ?? 'All'}, search: '$search'");
        Provider.of<Repository>(context, listen: false)
            .setSearchVideos(response.videos);
      } else {
        debugPrint("Search failed: ${response.message}");
        // Show empty results or error state
        Provider.of<Repository>(context, listen: false).setSearchVideos([]);
      }
    } catch (e) {
      Navigation.instance.goBack();
      debugPrint("Search error: $e");
      Provider.of<Repository>(context, listen: false).setSearchVideos([]);
    }
  }

  void suggest(String search) async {
    try {
      VideoResponse response;

      if (selectedCategory != null) {
        // Use getVideos API with category filter when a category is selected
        response = await ApiProvider.instance.getVideos(
          1,
          // page_no
          null,
          // language
          selectedCategory!.slug,
          // category slug
          null,
          // genre
          search.isEmpty ? null : search,
          // search term
          "search",
          // page type
          null, // type
        );
      } else {
        // Use regular search API when no category filter
        response = await ApiProvider.instance.search(search);
      }

      if (response.success ?? false) {
        Provider.of<Repository>(context, listen: false)
            .setSearchVideos(response.videos);
      }
    } catch (e) {
      debugPrint("Suggest error: $e");
    }
  }
}
