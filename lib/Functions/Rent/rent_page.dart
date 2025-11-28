import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/common_functions.dart';
import '../../Constants/constants.dart';
import '../../Helper/storage.dart';
import '../../Models/video.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/alert.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/grid_view_shimmering.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final ScrollController _scrollController = ScrollController();
  int page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigation.instance.goBack();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Colors.black,
        title: Text(
          "Rent",
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
          horizontal: 2.w,
        ),
        child: Consumer<Repository>(
          builder: (context, data, _) {
            // Check if we have rental videos
            if (data.specificVideos.isEmpty) {
              // Check if we've finished loading (add a loading state flag if needed)
              return FutureBuilder<void>(
                future: Future.delayed(Duration(seconds: 1)),
                // Give time for API call
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Constants.primaryColor,
                      child: const GridViewShimmering(),
                    );
                  } else {
                    // Show no data state after loading is complete
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            color: Colors.grey.shade600,
                            size: 20.w,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'No rental videos available',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Check back later for new content',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          ElevatedButton(
                            onPressed: () {
                              _checkNetworkAndFetchData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.secondaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            }

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Rentals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${data.specificVideos.length} titles available',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grid view
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController, 
                      itemCount: data.specificVideos.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.5.w,
                        mainAxisSpacing: 1.h,
                        childAspectRatio: 6.5 / 8.5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var item = data.specificVideos[index];
                        return OttItem(
                            item: item,
                            onTap: () {
                              if (Storage.instance.isLoggedIn) {
                                Navigation.instance.navigate(Routes.watchScreen,
                                    args: item.id);
                              } else {
                                CommonFunctions().showLoginDialog(context);
                              }
                            });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  fetchRentals(context) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getRentVideos();
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
    } else {
      Navigation.instance.goBack();
      showError(response.message ?? "Something went wrong");
    }
  }

  void showError(String msg) {
    AlertX.instance.showAlert(
        title: "Error",
        msg: msg,
        positiveButtonText: "Done",
        positiveButtonPressed: () {
          Navigation.instance.goBack();
        });
  }

  @override
  void initState() {
    super.initState();

    // Initialize data loading immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.rentScreen);
      _checkNetworkAndFetchData();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          debugPrint("Reached bottom - can implement pagination here");
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure correct navigation index when coming back to rent screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.rentScreen);
    });
  }

  void _checkNetworkAndFetchData() async {
    try {
      debugPrint("Starting network check and data fetch...");

      // Temporarily skip the rent-specific API and go directly to fallback
      // to test if authentication is the issue
      debugPrint(
          "Skipping rent-specific API, trying general videos API with rent filter...");
      final fallbackResponse = await ApiProvider.instance.getVideos(
        1,
        null,
        null,
        null,
        null,
        "rent",
        null,
      );

      debugPrint(
          "Fallback API response: success=${fallbackResponse.success}, message=${fallbackResponse.message}");
      debugPrint(
          "Fallback API response videos count: ${fallbackResponse.videos.length}");

      // Debug each fallback video
      for (int i = 0; i < fallbackResponse.videos.length; i++) {
        final video = fallbackResponse.videos[i];
        debugPrint("Fallback Video $i: id=${video.id}, title='${video.title}'");
      }

      if (fallbackResponse.success ?? false) {
        debugPrint("Fallback videos count: ${fallbackResponse.videos.length}");
        if (mounted) {
          Provider.of<Repository>(context, listen: false)
              .setSearchVideos(fallbackResponse.videos);
        }
        return;
      }

      // If fallback fails, try the original rent API
      final rentalResponse = await ApiProvider.instance.getRentVideos();
      debugPrint(
          "Rental API response: success=${rentalResponse.success}, message=${rentalResponse.message}");
      debugPrint(
          "Rental API response videos count: ${rentalResponse.videos.length}");

      // Debug each video
      for (int i = 0; i < rentalResponse.videos.length; i++) {
        final video = rentalResponse.videos[i];
        debugPrint("Rental Video $i: id=${video.id}, title='${video.title}'");
      }

      if (rentalResponse.success ?? false) {
        debugPrint("Rental videos count: ${rentalResponse.videos.length}");
        if (mounted) {
          Provider.of<Repository>(context, listen: false)
              .setSearchVideos(rentalResponse.videos);
        }
      } else {
        // If both APIs fail, set empty list to show no data state
        if (mounted) {
          Provider.of<Repository>(context, listen: false).setSearchVideos([]);
        }
      }
    } catch (e) {
      debugPrint("Network check error: $e");
      // Set empty list to show error state
      if (mounted) {
        Provider.of<Repository>(context, listen: false).setSearchVideos([]);
      }
    }
  }

  Future<List<Video>> fetchDetails(int page_no, String sections,
      String? category, String? genres, String? term) async {
    try {
      debugPrint("fetchDetails called with: page=$page_no, sections=$sections");

      final response = await ApiProvider.instance.getRentVideos();
      debugPrint(
          "fetchDetails API response: success=${response.success}, message=${response.message}");

      if (response.success ?? false) {
        debugPrint("fetchDetails videos count: ${response.videos.length}");
        return response.videos;
      } else {
        debugPrint("API Error: ${response.message}");

        final fallbackResponse = await ApiProvider.instance.getVideos(
          page_no,
          null,
          category,
          genres,
          term,
          "rent",
          null,
        );

        if (fallbackResponse.success ?? false) {
          debugPrint(
              "Fallback successful, videos count: ${fallbackResponse.videos.length}");
          return fallbackResponse.videos;
        }

        return List<Video>.empty();
      }
    } catch (e) {
      debugPrint("Exception in fetchDetails: $e");
      return List<Video>.empty();
    }
  }
}
