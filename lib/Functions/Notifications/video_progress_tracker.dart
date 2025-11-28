import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../../Models/watch_progress_model.dart';
import 'watch_progress_service.dart';

class VideoProgressTracker {
  final WatchProgressService _progressService = WatchProgressService();
  Timer? _progressTimer;
  VideoPlayerController? _controller;
  WatchProgressModel? _currentProgress;

  // Initialize tracker with video details
  void initialize({
    required VideoPlayerController controller,
    required String contentId,
    required String contentType,
    required String title,
    String? seriesId,
    String? episodeId,
    String? seasonNumber,
    String? episodeNumber,
    String? thumbnailUrl,
    int? resumeFromPosition,
  }) {
    _controller = controller;

    _currentProgress = WatchProgressModel(
      contentId: contentId,
      contentType: contentType,
      title: title,
      seriesId: seriesId,
      episodeId: episodeId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      currentPosition: resumeFromPosition ?? 0,
      totalDuration: controller.value.duration.inSeconds,
      thumbnailUrl: thumbnailUrl,
      lastWatched: DateTime.now(),
    );

    debugPrint('🎬 VideoProgressTracker initialized');
    debugPrint('📺 Content: $title');
    if (contentType == 'series') {
      debugPrint(
          '📺 Series: $seriesId, Episode: $episodeId (S${seasonNumber}E${episodeNumber})');
    }
    debugPrint('⏱️ Total duration: ${controller.value.duration.inSeconds}s');

    // Resume from saved position if provided
    if (resumeFromPosition != null && resumeFromPosition > 0) {
      final resumePosition = Duration(seconds: resumeFromPosition);
      controller.seekTo(resumePosition);
      debugPrint(
          '▶️ Auto-resuming from: ${resumeFromPosition}s (${(resumeFromPosition / 60).toStringAsFixed(1)} min)');

      // Auto-play when resuming from notification
      controller.play();
    }

    // Start tracking progress
    _startProgressTracking();
  }

  // Start periodic progress tracking
  void _startProgressTracking() {
    _progressTimer?.cancel();

    // Save progress every 10 seconds while playing
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateProgress();
    });

    debugPrint('Started video progress tracking');
  }

  // Update current progress
  void _updateProgress() {
    if (_controller == null || _currentProgress == null) return;

    final position = _controller!.value.position.inSeconds;
    final duration = _controller!.value.duration.inSeconds;

    if (position > 0 && duration > 0) {
      _currentProgress = _currentProgress!.copyWith(
        currentPosition: position,
        totalDuration: duration,
        lastWatched: DateTime.now(),
      );

      // Save to storage periodically
      _progressService.saveWatchProgress(_currentProgress!);

      // Log progress for series episodes
      if (_currentProgress!.contentType == 'series') {
        debugPrint(
            '📺 Series progress: ${_currentProgress!.title} S${_currentProgress!.seasonNumber}E${_currentProgress!.episodeNumber} - ${position}s/${duration}s (${(_currentProgress!.currentPosition / _currentProgress!.totalDuration * 100).toStringAsFixed(1)}%)');
      } else {
        debugPrint(
            '🎬 Movie progress: ${_currentProgress!.title} - ${position}s/${duration}s (${(_currentProgress!.currentPosition / _currentProgress!.totalDuration * 100).toStringAsFixed(1)}%)');
      }
    }
  }

  // Call when video is paused
  void onPause() {
    _updateProgress();
    debugPrint('Video paused - progress saved');
  }

  // Call when video is resumed
  void onResume() {
    _updateProgress();
    debugPrint('Video resumed');
  }

  // Call when user seeks to different position
  void onSeek(Duration position) {
    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        currentPosition: position.inSeconds,
        lastWatched: DateTime.now(),
      );
      _progressService.saveWatchProgress(_currentProgress!);
      debugPrint('Video seeked to: ${position.inSeconds}s');
    }
  }

  // Call when video completes
  void onComplete() {
    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        currentPosition: _currentProgress!.totalDuration,
        lastWatched: DateTime.now(),
        isCompleted: true,
      );
      _progressService.markAsCompleted(_currentProgress!.contentId);
      debugPrint('Video completed: ${_currentProgress!.title}');
    }
  }

  // Call when user exits video (back button, navigation, etc.)
  void onExit() {
    _updateProgress();
    debugPrint('Video exited - final progress saved');
  }

  // Manual save (call when app goes to background)
  void saveCurrentProgress() {
    _updateProgress();
  }

  // Get current watch progress
  WatchProgressModel? getCurrentProgress() => _currentProgress;

  // Get current position as percentage
  double getCurrentProgressPercentage() {
    if (_currentProgress == null || _currentProgress!.totalDuration == 0) {
      return 0.0;
    }
    return (_currentProgress!.currentPosition /
        _currentProgress!.totalDuration) * 100;
  }

  // Check if video should be auto-resumed
  bool shouldAutoResume() {
    if (_currentProgress == null) return false;
    return _currentProgress!.currentPosition >
        30; // Resume if watched more than 30 seconds
  }

  // Dispose and cleanup
  void dispose() {
    _progressTimer?.cancel();
    onExit(); // Save final progress
    _controller = null;
    _currentProgress = null;
    debugPrint('Video progress tracker disposed');
  }
}

// Extension to make VideoPlayerController integration easier
extension VideoPlayerControllerProgress on VideoPlayerController {
  VideoProgressTracker createProgressTracker({
    required String contentId,
    required String contentType,
    required String title,
    String? seriesId,
    String? episodeId,
    String? seasonNumber,
    String? episodeNumber,
    String? thumbnailUrl,
    int? resumeFromPosition,
  }) {
    final tracker = VideoProgressTracker();
    tracker.initialize(
      controller: this,
      contentId: contentId,
      contentType: contentType,
      title: title,
      seriesId: seriesId,
      episodeId: episodeId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      thumbnailUrl: thumbnailUrl,
      resumeFromPosition: resumeFromPosition,
    );
    return tracker;
  }
}