import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/description_section.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/episode_slider_new.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/info_bar.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/more_like_this_section.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/options_bar.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/rent_bottom_sheet.dart';
import 'package:niri9/Functions/WatchScreen/Widgets/trailer_widget.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WatchScreenNew extends StatefulWidget {
  const WatchScreenNew({super.key, required this.id});
  final int id;

  @override
  State<WatchScreenNew> createState() => _WatchScreenNewState();
}

class _WatchScreenNewState extends State<WatchScreenNew> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoAvailable = true;
  bool _isPlayLoading = false;
  bool _isInitializing = true;
  bool _trailerPlayer = false;
  bool _isDisposed = false;
  int? _currentPlayingEpisodeId; // Track currently playing episode

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isDisposed) return;

    try {
      await WakelockPlus.enable();

      // Start all API calls in parallel immediately
      final futures = <Future>[
        _fetchVideoDetails(widget.id),
        _fetchRentDetails(widget.id),
      ];

      // Execute all in parallel
      await Future.wait(futures);
    } catch (e) {
      debugPrint("Error during initialization: $e");
      if (mounted && !_isDisposed) {
        setState(() {
          _isVideoAvailable = false;
          _isInitializing = false;
        });
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _fetchDetails(int id) async {
    if (_isDisposed) return;

    try {
      // Execute both API calls in parallel
      await Future.wait([
        _fetchVideoDetails(id),
        _fetchRentDetails(id),
      ]);
    } catch (e) {
      debugPrint("Error fetching details: $e");
      if (mounted && !_isDisposed) {
        setState(() => _isVideoAvailable = false);
      }
    }
  }

  Future<void> _fetchRentDetails(int id) async {
    if (_isDisposed) return;

    try {
      final response = await ApiProvider.instance.getRentPlans(id);
      if ((response.success ?? false) && mounted && !_isDisposed) {
        Provider.of<Repository>(context, listen: false)
            .setRentPlanDetails(response.result);
      }
    } catch (e) {
      debugPrint("Error fetching rent details: $e");
    }
  }

  Future<void> _fetchVideoDetails(int index) async {
    if (_isDisposed) return;

    final repo = Provider.of<Repository>(context, listen: false);
    repo.setLoading(true);

    try {
      final response = await ApiProvider.instance.getVideoDetails(index);
      if (_isDisposed) return;

      if (response.success ?? false) {
        repo.setVideoDetails(response.video!);

        // Initialize player without awaiting if we have permission
        final permission = response.video?.view_permission ?? false;
        if (permission) {
          // Start player initialization in background (don't await)
          _initializePlayerAsync(repo);
        }
      } else {
        if (mounted && !_isDisposed) {
          setState(() => _isVideoAvailable = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching video: $e");
      if (mounted && !_isDisposed) {
        setState(() => _isVideoAvailable = false);
      }
    } finally {
      if (mounted && !_isDisposed) {
        repo.setLoading(false);
      }
    }
  }

  // Non-blocking player initialization
  Future<void> _initializePlayerAsync(Repository repo) async {
    if (_isDisposed) return;

    try {
      final permission = repo.videoDetails?.view_permission ?? false;
      if (!permission) return;

      final videos = repo.videoDetails?.videos;
      if (videos == null || videos.isEmpty) {
        debugPrint("No videos available");
        return;
      }

      final videoUrl = videos.first.videoPlayer;
      if (videoUrl == null || videoUrl.isEmpty) {
        debugPrint("Invalid video URL");
        return;
      }

      // Set the first episode as currently playing
      if (_currentPlayingEpisodeId == null && videos.isNotEmpty) {
        _currentPlayingEpisodeId = videos.first.id;
      }

      // Dispose existing controllers before creating new ones
      await _disposeControllers();

      // Create and initialize player
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // Initialize player and create chewie controller in parallel
      await _videoPlayerController?.initialize();

      if (_isDisposed || _videoPlayerController == null) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: repo.user?.has_subscription ?? false,
        looping: false,
        aspectRatio: _videoPlayerController?.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );

      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing player: $e");
      if (mounted && !_isDisposed) {
        setState(() => _isVideoAvailable = false);
      }
    }
  }

  Future<void> _disposeControllers() async {
    try {
      await _videoPlayerController?.pause();
      await _chewieController?.pause();
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
      _chewieController = null;
      _videoPlayerController = null;
    } catch (e) {
      debugPrint("Error disposing controllers: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeControllers();
    WakelockPlus.disable().catchError((e) {
      debugPrint("Error disabling wakelock: $e");
    });
    super.dispose();
  }

  Future<void> _changeVideo(String videoUrl) async {
    if (!mounted || _isDisposed) return;

    if (videoUrl.isEmpty) {
      debugPrint("Invalid video URL provided");
      return;
    }

    setState(() => _isPlayLoading = true);

    try {
      // Dispose controllers and create new ones in parallel where possible
      await _disposeControllers();

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // Initialize player
      await _videoPlayerController?.initialize();

      if (_isDisposed || _videoPlayerController == null) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController?.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );
    } catch (e) {
      debugPrint("Error changing video: $e");
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isPlayLoading = false);
      }
    }
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Constants.primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(Assets.notFoundAnimation),
          const Text("This Movie/WebSeries is not available"),
          SizedBox(height: 2.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: Navigation.instance.goBack,
            child: Text(
              "Go Back",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(Repository store) {
    final hasPermission = store.videoDetails?.view_permission ?? false;
    final hasAccess = (store.user?.has_subscription ?? false);
    final hasRent = store.videoDetails?.has_rent ?? false;
    final hasPlan = store.videoDetails?.has_plan ?? false;

    // Show video player if we have a controller and any of these conditions are met:
    // 1. Has permission and access (subscription)
    // 2. Has permission but no rent requirement
    // 3. Trailer is playing
    // 4. Has permission and rent but no plan needed
    if (_chewieController != null &&
        ((hasPermission && hasAccess) ||
            (hasPermission && !hasRent) ||
            _trailerPlayer ||
            (hasPermission && hasRent && hasPlan))) {
      return SizedBox(
        height: 28.h,
        child: Center(
          child: _isPlayLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 28.h,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                )
              : Chewie(controller: _chewieController!),
        ),
      );
    }

    if (!hasPermission && hasRent && !hasPlan) {
      return SizedBox(
        height: 28.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStyledButton(
              onPressed: () {
                showRenting(context, store.videoDetails);
              },
              text: "Rent",
              icon: Icons.movie_creation_outlined,
              color: Colors.orange,
              width: 120, 
            ),
          ],
        ),
      );
    }

    if (!hasPermission && hasRent && hasPlan) {
      return SizedBox(
        height: 28.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStyledButton(
              onPressed: () {
                showRenting(context, store.videoDetails).then((_) {
                  _fetchVideoDetails(widget.id);
                  _fetchRentDetails(widget.id);
                });
              },
              text: "Rent",
              icon: Icons.movie_creation_outlined,
              color: Colors.orange,
              width: 140,
            ),
            const SizedBox(height: 12),
            _buildStyledButton(
              onPressed: () {
                Navigation.instance
                    .navigate(Routes.subscriptionScreen)!
                    .then((_) {
                  _fetchVideoDetails(widget.id);
                  _fetchRentDetails(widget.id);
                });
              },
              text: "Subscribe",
              icon: Icons.star_outline,
              color: Colors.blue,
              width: 140,
            ),
          ],
        ),
      );
    }
    if (!hasPermission || !hasAccess) {
      _disposeControllers();
    }

    return SizedBox(
      height: 28.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please Subscribe to Watch this Content",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildStyledButton(
            onPressed: () =>
                Navigation.instance.navigate(Routes.subscriptionScreen),
            text: "Subscribe",
            icon: Icons.star_outline,
            color: Colors.blue,
            width: 140,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
    double width = 120,
  }) {
    return Container(
      width: width,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonSelector(Repository store) {
    final seasonList = store.videoDetails?.season_list;
    if (seasonList == null || seasonList.isEmpty) return const SizedBox();

    return Column(
      children: [
        Container(
          height: 40,
          margin: EdgeInsets.only(left: 8.w),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: seasonList.length,
            itemBuilder: (context, index) {
              final season = seasonList[index];
              final isSelected = season == store.selectedSeason;
              return GestureDetector(
                onTap: () => Provider.of<Repository>(context, listen: false)
                    .changeSeason(season),
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${season.season}",
                    style:  TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAdBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5.w,
            color: Colors.yellow,
            child: Center(
              child: Text(
                "Ad",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse("https://niri9.com/backend")),
            child: Image.asset(
              Assets.addPopupImage,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, store, child) {
      if (_isInitializing) {
        return Scaffold(
          body: _buildShimmerScreen(),
        );
      }

      if (!_isVideoAvailable) {
        return Scaffold(body: _buildErrorScreen(context));
      }

      return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, size: 20.sp),
                        color: Colors.white,
                        onPressed: () {
                          EasyLoading.dismiss();
                          Navigation.instance.goBack();
                        },
                      ),
                    ],
                  ),
                ),
                _buildVideoPlayer(store),
                const InfoBar(),
                OptionsBar(
                  onEpisodeTap: (String url) {
                    if (url.isNotEmpty) {
                      setState(() {
                        _trailerPlayer = true;
                        _currentPlayingEpisodeId =
                            null; // Clear episode selection for trailer
                      });
                      _changeVideo(url);
                    }
                  },
                ),
                const DescriptionSection(),
                SizedBox(height: 10),
                _buildSeasonSelector(store),
                if (store.videoDetails?.videos != null &&
                    store.videoDetails?.video_type_id == 2)
                  EpisodeSliderNew(
                    episodes: store.videoDetails!.videos!,
                    currentPlayingEpisodeId: _currentPlayingEpisodeId,
                    onEpisodeTap: (VideoDetails video) {
                      if (store.user?.has_subscription ?? false) {
                        final videoUrl = video.videoPlayer;
                        if (videoUrl != null && videoUrl.isNotEmpty) {
                          setState(() {
                            _currentPlayingEpisodeId = video.id;
                          });
                          _changeVideo(videoUrl);
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Please Subscribe First");
                      }
                    },
                  ),
                _buildAdBanner(),
                if (_chewieController != null && store.videoDetails != null)
                  MoreLikeThisSection(
                    chewieController: _chewieController!,
                    data: store.videoDetails!,
                  ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShimmerScreen() {
    return Container(
      color: Constants.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // App bar shimmer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              color: Colors.black,
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    child: Container(
                      width: 8.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video player shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[600]!,
              highlightColor: Colors.grey[400]!,
              child: Container(
                height: 28.h,
                width: double.infinity,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 2.h),

            // Info bar shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    child: Container(
                      height: 3.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    child: Container(
                      height: 2.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Options bar shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (index) => Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    child: Container(
                      height: 5.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Description shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[600]!,
                      highlightColor: Colors.grey[400]!,
                      child: Container(
                        height: 2.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Episodes shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    child: Container(
                      height: 2.5.h,
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 20.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.only(right: 3.w),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[600]!,
                          highlightColor: Colors.grey[400]!,
                          child: Container(
                            width: 35.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> showRenting(BuildContext context, Video? videoDetails) async {
    return showModalBottomSheet(
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      context: context,
      builder: (_) => RentBottomSheet(videoDetails: videoDetails),
    );
  }
}
