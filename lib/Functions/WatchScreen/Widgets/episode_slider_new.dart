import 'package:flutter/material.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

class EpisodeSliderNew extends StatelessWidget {
  final List<VideoDetails> episodes;
  final Function(VideoDetails) onEpisodeTap;
  final int? currentPlayingEpisodeId;

  const EpisodeSliderNew({
    super.key,
    required this.episodes,
    required this.onEpisodeTap,
    this.currentPlayingEpisodeId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index];
          final isCurrentlyPlaying = currentPlayingEpisodeId == episode.id;

          return GestureDetector(
            onTap: () => onEpisodeTap(episode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 45.w,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isCurrentlyPlaying
                    ? Colors.red.shade900.withOpacity(0.3)
                    : Colors.grey.shade900,
                border: Border.all(
                  color: isCurrentlyPlaying
                      ? Colors.red.shade600
                      : Colors.grey.shade700,
                  width: isCurrentlyPlaying ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrentlyPlaying
                        ? Colors.red.withOpacity(0.3)
                        : Colors.black.withOpacity(0.4),
                    blurRadius: isCurrentlyPlaying ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                // height: 20.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16),
                  ),
                  color: Colors.grey.shade800,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: episode.profile_pic ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade700,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                color: Colors.grey.shade400,
                                size: 10.w,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Episode ${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    // Positioned.fill(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: const BorderRadius.only(
                    //         topLeft: Radius.circular(16),
                    //         topRight: Radius.circular(16),
                    //       ),
                    //       gradient: LinearGradient(
                    //         begin: Alignment.center,
                    //         end: Alignment.bottomCenter,
                    //         colors: [
                    //           Colors.transparent,
                    //           Colors.black.withOpacity(0.4),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Play/Currently Playing indicator
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrentlyPlaying
                                ? Colors.red.withOpacity(0.9)
                                : Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCurrentlyPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: isCurrentlyPlaying ? 32 : 28,
                          ),
                        ),
                      ),
                    ),
                    // "Now Playing" badge for current episode
                    if (isCurrentlyPlaying)
                      Positioned(
                        top: 1.h,
                        right: 1.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.w,
                            vertical: 0.2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    // Episode number badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'EP ${index + 1}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
