import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/Search/Widgets/genre_select_button.dart';
import 'package:niri9/Models/genres.dart';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<Repository>(context, listen: false).updateIndex(1);
      selectedGenre = Provider.of<Repository>(context, listen: false).genres[0];
      selectedCategory =
          Provider.of<Repository>(context, listen: false).categories[0];
      selectedSections =
          Provider.of<Repository>(context, listen: false).homeSections[0];
      setState(() {});
      if (widget.filters != "") {
        selectedCategory = Provider.of<Repository>(context, listen: false)
            .categories
            .firstWhere((element) => element.name == widget.filters);
        search("");
      } else {
        search("");
      }
    });
    searchEditingController.addListener(() {
      setState(() {
        currentSearch = searchEditingController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(12.4.h),
        child: SearchAppbar(
          searchEditingController: searchEditingController,
          search: (String val) {
            search(val);
          },
          suggest: (String val) {
            suggest(val);
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.5.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consumer<Repository>(builder: (context, data, _) {
            //   return Container(
            //     width: double.infinity,
            //     height: 4.h,
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 2.w,
            //     ),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         GenreSelectButton(
            //           selectedGenre: selectedGenre,
            //           onChanged: (Genres? newValue) {
            //             setState(() {
            //               selectedGenre = newValue!;
            //             });
            //           },
            //           data: data,
            //         ),
            //         // SizedBox(
            //         //   width: 2.w,
            //         // ),
            //         // SectionSelectButton(
            //         //   selectedSection: selectedSections,
            //         //   onChanged: (Sections? newValue) {
            //         //     setState(() {
            //         //       selectedSections = newValue!;
            //         //     });
            //         //   },
            //         //   data: data,
            //         // ),
            //         // SizedBox(
            //         //   width: 2.w,
            //         // ),
            //         CategorySelectButton(
            //           selectedCategory: selectedCategory,
            //           onChanged: (Category? newValue) {
            //             setState(() {
            //               selectedCategory = newValue!;
            //             });
            //           },
            //           data: data,
            //         ),
            //       ],
            //     ),
            //   );
            // }),
            // SizedBox(
            //   height: 2.h,
            // ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 1.5.h,
                left: 2.5.w,
              ),
              child: Text(
                currentSearch == "" ? "Today's Top Searches" : "",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      // fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Consumer<Repository>(builder: (context, data, _) {
              return Expanded(
                child: GridView.builder(
                  itemCount: data.specificVideos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 0.5.h,
                    childAspectRatio: 8.5 / 11,
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
            }),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  void search(String search) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.search(search);
    if (response.success ?? false) {
      Navigation.instance.goBack();
      debugPrint("Search ${response.videos.length}");
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
    } else {
      Navigation.instance.goBack();
    }
  }

  void suggest(String search) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.search(search);
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
    } else {
      // Navigation.instance.goBack();
    }
  }
}
