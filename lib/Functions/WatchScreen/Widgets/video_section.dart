import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_touch_ripple/widgets/widget.dart';
import 'package:sizer/sizer.dart';

class VideoSection extends StatelessWidget {
  const VideoSection({
    super.key,
    required CustomVideoPlayerController customVideoPlayerController,
    required this.isPlaying,
    required this.showing,
    required this.onClicked,
  }) : _customVideoPlayerController = customVideoPlayerController;

  final CustomVideoPlayerController _customVideoPlayerController;
  final bool isPlaying, showing;
  final Function onClicked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      child: Stack(
        // alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.black,
            height: 28.h,
            width: double.infinity,
            child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 20.h,
              // color: Colors.grey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     _customVideoPlayerController.videoPlayerController.seekTo(_customVideoPlayerController.videoPlayerController.value.position-const Duration(seconds: 10));
                  //   },
                  //   icon: const Icon(
                  //     FontAwesomeIcons.backward,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // IconButton(
                  //   splashColor: Colors.grey.shade300,
                  //   onPressed: () {
                  //     isPlaying?_customVideoPlayerController.videoPlayerController.pause():_customVideoPlayerController.videoPlayerController.play();
                  //   },
                  //   icon:  Icon(
                  //     isPlaying?FontAwesomeIcons.pause:FontAwesomeIcons.play,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     _customVideoPlayerController.videoPlayerController.seekTo(_customVideoPlayerController.videoPlayerController.value.position+const Duration(seconds: 10));
                  //   },
                  //   icon: const Icon(
                  //     FontAwesomeIcons.fastForward,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  Material(
                    color: Colors.grey.withOpacity(0.1),
                    child: Container(
                      // color: Colors.red,
                      child: InkWell(
                        splashColor: Colors.white,
                        // behavior: HitTestBehavior.translucent,
                        radius: 30.w,
                        // behavior: HitTestBehavior.translucent,
                        onDoubleTap: () {
                          _customVideoPlayerController.videoPlayerController.seekTo(
                              _customVideoPlayerController
                                      .videoPlayerController.value.position -
                                  const Duration(seconds: 10));
                          debugPrint("BackWard");
                        },
                        // rippleColor: Colors.white,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.w,
                          ),
                          child: Icon(
                            Icons.fast_rewind,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Material(
                    color: Colors.grey.withOpacity(0.05),
                    child: Container(
                      // color: Colors.red,
                      child: InkWell(
                        splashColor: Colors.white,
                        // behavior: HitTestBehavior.translucent,
                        radius: 30.w,
                        // behavior: HitTestBehavior.translucent,
                        onDoubleTap: () {
                          _customVideoPlayerController.videoPlayerController.seekTo(
                              _customVideoPlayerController
                                  .videoPlayerController.value.position +
                                  const Duration(seconds: 10));
                        },
                        // rippleColor: Colors.white,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.w,
                          ),
                          child: Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // TouchRipple(
                  //   onDoubleTap: () {
                  //     _customVideoPlayerController.videoPlayerController.seekTo(
                  //         _customVideoPlayerController
                  //                 .videoPlayerController.value.position +
                  //             const Duration(seconds: 10));
                  //   },
                  //   rippleColor: Colors.white,
                  //   child: Padding(
                  //     padding: EdgeInsets.all(10.w),
                  //     child: Icon(
                  //       Icons.fast_forward,
                  //       color: Colors.transparent,
                  //       size: 30.sp,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              //       :GestureDetector(
              //   onTap: ()=>onClicked(),
              //   child: Container(
              //     width: 50.w,
              //     color: Colors.transparent,
              //   ),
              // ),
            ),
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Container(
          //     padding: EdgeInsets.symmetric(
          //       horizontal: 3.w,
          //     ),
          //     height: 4.h,
          //     width: double.infinity,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         Container(
          //          decoration: BoxDecoration(
          //            color: Colors.black.withOpacity(0.05),
          //            shape: BoxShape.circle,
          //          ),
          //           child: IconButton(
          //             onPressed: () {
          //               Navigation.instance.goBack();
          //             },
          //             icon: const Icon(
          //               Icons.arrow_back,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //         // Container(
          //         //   decoration: BoxDecoration(
          //         //     color: Colors.black.withOpacity(0.05),
          //         //     shape: BoxShape.circle,
          //         //   ),
          //         //   child: IconButton(
          //         //     onPressed: () {
          //         //       Navigation.instance.goBack();
          //         //     },
          //         //     icon: const Icon(
          //         //       Icons.settings,
          //         //       color: Colors.white,
          //         //     ),
          //         //   ),
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
