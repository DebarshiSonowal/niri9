import 'package:chewie/chewie.dart';
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
  int? _currentPlayingEpisodeId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isDisposed) return;
    try {
      await WakelockPlus.enable();
      final futures = <Future>[
        _fetchVideoDetails(widget.id),
        _fetchRentDetails(widget.id),
      ];
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
        final videoDetails = repo.videoDetails;
        if (videoDetails == null) {
          debugPrint("Video details is null");
          return;
        }

        final hasSubscription = repo.user?.has_subscription ?? false;
        final isRentalContent = videoDetails.has_rent ?? false;
        final viewPermission = videoDetails.view_permission ?? false;

        // Access Logic:
        // 1. If subscribed → can watch everything
        // 2. If view_permission is true → user has rented/has access
        // 3. Otherwise → deny access
        final canWatchContent = hasSubscription || viewPermission;

        debugPrint(
            "Access Check: hasSubscription=$hasSubscription, isRental=$isRentalContent, "
            "viewPermission=$viewPermission, canWatch=$canWatchContent");

        if (canWatchContent) {
          debugPrint("User has access - initializing player");
          _initializePlayerAsync(repo);
        } else {
          debugPrint("User does not have access");
          if (mounted && !_isDisposed) {
            setState(() {});
          }
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

  Future<void> _initializePlayerAsync(Repository repo) async {
    if (_isDisposed) return;
    try {
      final hasSubscription = repo.user?.has_subscription ?? false;
      final viewPermission = repo.videoDetails?.view_permission ?? false;
      final canWatchContent = hasSubscription || viewPermission;

      if (!canWatchContent) {
        debugPrint("Cannot initialize: access denied");
        return;
      }

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

      if (_currentPlayingEpisodeId == null && videos.isNotEmpty) {
        _currentPlayingEpisodeId = videos.first.id;
      }

      await _disposeControllers();

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController?.initialize();

      if (_isDisposed || _videoPlayerController == null) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: hasSubscription || viewPermission,
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
      debugPrint("Invalid video URL");
      return;
    }

    final repo = Provider.of<Repository>(context, listen: false);
    final hasSubscription = repo.user?.has_subscription ?? false;
    final viewPermission = repo.videoDetails?.view_permission ?? false;
    final canWatchContent = hasSubscription || viewPermission;

    if (!canWatchContent) {
      Fluttertoast.showToast(msg: "Please Subscribe or Rent First");
      return;
    }

    setState(() => _isPlayLoading = true);
    try {
      await _disposeControllers();
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
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
    final hasSubscription = store.user?.has_subscription ?? false;
    final videoDetails = store.videoDetails;

    if (videoDetails == null) {
      return _buildShimmerPlaceholder();
    }

    final isRentalContent = videoDetails.has_rent ?? false;
    final viewPermission = videoDetails.view_permission ?? false;

    // Access Logic:
    // 1. If subscribed → can watch everything
    // 2. If view_permission is true → user has rented/has access
    // 3. Otherwise → show appropriate overlay
    final canWatchContent = hasSubscription || viewPermission;

    debugPrint(
        "VideoPlayer: subscription=$hasSubscription, rental=$isRentalContent, "
        "viewPermission=$viewPermission, canWatch=$canWatchContent, "
        "controller=${_chewieController != null}");

    // Case 1: User can watch and controller is ready
    if (canWatchContent && _chewieController != null) {
      return SizedBox(
        height: 28.h,
        child: _isPlayLoading
            ? _buildShimmerPlaceholder()
            : Chewie(controller: _chewieController!),
      );
    }

    // Case 2: User can watch but controller still loading
    if (canWatchContent && _chewieController == null) {
      return _buildShimmerPlaceholder();
    }

    // Case 3: No subscription and no valid rental - show access overlay
    return _buildAccessOverlay(
      title: "Access Required",
      subtitle: isRentalContent
          ? "Subscribe to watch all content, or rent this movie"
          : "Subscribe to unlock this exclusive content",
      buttonText: isRentalContent ? "Rent or Subscribe" : "Subscribe",
      buttonIcon:
          isRentalContent ? Icons.movie_creation_outlined : Icons.star_outline,
      buttonColor: isRentalContent ? Colors.orange : Colors.blue,
      onPressed: () {
        if (isRentalContent) {
          // Show rental bottom sheet
          showRenting(context, videoDetails).then((_) {
            _fetchVideoDetails(widget.id);
            _fetchRentDetails(widget.id);
          });
        } else {
          // Go to subscription screen
          Navigation.instance.navigate(Routes.subscriptionScreen);
        }
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return SizedBox(
      height: 28.h,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 28.h,
          width: double.infinity,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAccessOverlay({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData buttonIcon,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 28.h,
      child: Stack(
        children: [
          // Background
          Container(
            height: 28.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black87,
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                    SizedBox(height: 2.5.h),
                    // Button
                    _buildActionButton(
                      onPressed: onPressed,
                      text: buttonText,
                      icon: buttonIcon,
                      color: buttonColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          splashColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 1.5.w),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
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
                    style: TextStyle(
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
                      final hasSubscription =
                          store.user?.has_subscription ?? false;
                      final viewPermission =
                          store.videoDetails?.view_permission ?? false;
                      final canWatch = hasSubscription || viewPermission;

                      if (canWatch) {
                        setState(() {
                          _trailerPlayer = true;
                          _currentPlayingEpisodeId = null;
                        });
                        _changeVideo(url);
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Subscribe or Rent this Content");
                        showRenting(context, store.videoDetails);
                      }
                    }
                  },
                ),
                const DescriptionSection(),
                SizedBox(height: 10),
                _buildSeasonSelector(store),
                if (store.videoDetails?.videos != null &&
                    store.videoDetails?.video_type_id == 2)
                  EpisodeSliderNew(
                    episodes: store.videoDetails!.videos,
                    currentPlayingEpisodeId: _currentPlayingEpisodeId,
                    onEpisodeTap: (VideoDetails video) {
                      final hasSubscription =
                          store.user?.has_subscription ?? false;
                      final viewPermission =
                          store.videoDetails?.view_permission ?? false;
                      final canWatch = hasSubscription || viewPermission;

                      if (canWatch) {
                        final videoUrl = video.videoPlayer;
                        if (videoUrl != null && videoUrl.isNotEmpty) {
                          setState(() {
                            _currentPlayingEpisodeId = video.id;
                            _trailerPlayer = false;
                          });
                          _changeVideo(videoUrl);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Subscribe or Rent this Content");
                        showRenting(context, store.videoDetails);
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
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> showRenting(BuildContext context, Video? videoDetails) async {
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => RentBottomSheet(videoDetails: videoDetails),
    );
  }
}
