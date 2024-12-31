import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class VideoSection extends StatelessWidget {
  const VideoSection({
    super.key,
    required CachedVideoPlayerPlusController customVideoPlayerController,
    required this.isPlaying,
    required this.showing,
    required this.onClicked,
    required this.updateIsPlaying,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CachedVideoPlayerPlusController _customVideoPlayerController;
  final bool isPlaying;
  final bool showing;
  final Function onClicked;
  final Function(bool) updateIsPlaying;

  /// Helper methods for clarity
  void _rewind10s() {
    final currentPosition = _customVideoPlayerController.value.position;
    _customVideoPlayerController.seekTo(
      currentPosition - const Duration(seconds: 10),
    );
  }

  void _forward10s() {
    final currentPosition = _customVideoPlayerController.value.position;
    _customVideoPlayerController.seekTo(
      currentPosition + const Duration(seconds: 10),
    );
  }

  void _togglePlayPause() {
    if (_customVideoPlayerController.value.isPlaying) {
      _customVideoPlayerController.pause();
    } else {
      _customVideoPlayerController.play();
      updateIsPlaying(true);
    }
  }

  Future<void> _toggleFullScreen(BuildContext context) async {
    // Hide system UI for full screen experience
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideo(
          customVideoPlayerController: _customVideoPlayerController,
          togglePlayPause: _togglePlayPause,
          rewind10s: _rewind10s,
          forward10s: _forward10s,
          formatDuration: _formatDuration,
        ),
      ),
    );

    // Restore system UI and orientation after exiting full screen
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String _formatDuration(Duration position) {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: double.infinity,
      child: Stack(
        children: [
          // MAIN VIDEO
          GestureDetector(
            // Call your onClicked (e.g. to toggle "showing" in a parent widget)
            onTap: () => onClicked(),
            child: CachedVideoPlayerPlus(_customVideoPlayerController),
          ),

          // OVERLAY CONTROLS (only if 'showing' == true)
          if (showing) ...[
            Container(
              color: Colors.black45, // Dim the background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// PLAYBACK CONTROL ROW
                  SizedBox(
                    height: 4.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _rewind10s,
                        icon: Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: _forward10s,
                        icon: Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

                  /// PROGRESS INDICATOR
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 7.h),
                    child: VideoProgressIndicator(
                      _customVideoPlayerController,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.redAccent,
                        backgroundColor: Colors.grey.shade700,
                        bufferedColor: Colors.grey,
                      ),
                    ),
                  ),

                  /// TIMESTAMPS and Fullscreen Button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_customVideoPlayerController.value.position.inMinutes}:${(_customVideoPlayerController.value.position.inSeconds % 60).toString().padLeft(2, '0')}/${_customVideoPlayerController.value.duration.inMinutes}:${(_customVideoPlayerController.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleFullScreen(context),
                          icon: Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenVideo extends StatefulWidget {
  const FullScreenVideo({
    super.key,
    required this.customVideoPlayerController,
    required this.togglePlayPause,
    required this.rewind10s,
    required this.forward10s,
    required this.formatDuration,
  });

  final CachedVideoPlayerPlusController customVideoPlayerController;
  final Function togglePlayPause, rewind10s, forward10s, formatDuration;

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  bool isStretched = false;
  bool controlsVisible = true;
  Timer? hideControlsTimer;

  void startHideControlsTimer() {
    hideControlsTimer?.cancel();
    hideControlsTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        controlsVisible = false;
      });
    });
  }

  void showControls() {
    setState(() {
      controlsVisible = true;
    });
    startHideControlsTimer();
  }

  void hideControls() {
    setState(() {
      controlsVisible = false;
    });
    hideControlsTimer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => startHideControlsTimer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: showControls, // Changed to show controls on tap
              onDoubleTap: () {
                setState(() {
                  isStretched = !isStretched;
                });
              },
              child: Center(
                child: CachedVideoPlayerPlus(
                  widget.customVideoPlayerController,
                ),
              ),
            ),
            if (controlsVisible)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap:
                      showControls, // Ensure controls remain visible on interaction
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// PLAYBACK CONTROL ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () =>
                                widget.rewind10s(), // Removed parentheses
                            icon: Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.togglePlayPause();
                              setState(() {}); // Refresh to update icon
                              startHideControlsTimer(); // Restart hide timer
                            },
                            icon: Icon(
                              widget.customVideoPlayerController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                widget.forward10s(), // Removed parentheses
                            icon: Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8.h,
                      ),

                      /// PROGRESS INDICATOR
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: VideoProgressIndicator(
                          widget.customVideoPlayerController,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          colors: VideoProgressColors(
                            playedColor: Colors.redAccent,
                            backgroundColor: Colors.grey.shade700,
                            bufferedColor: Colors.grey,
                          ),
                        ),
                      ),

                      /// TIMESTAMPS and Fullscreen Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.formatDuration(widget.customVideoPlayerController.value.position)}/${widget.formatDuration(widget.customVideoPlayerController.value.duration)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
