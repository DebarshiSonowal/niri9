class WatchProgressModel {
  final String contentId;
  final String contentType; // 'movie' or 'series'
  final String title;
  final String? seriesId;
  final String? episodeId;
  final String? seasonNumber;
  final String? episodeNumber;
  final int currentPosition; // in seconds
  final int totalDuration; // in seconds
  final String? thumbnailUrl;
  final DateTime lastWatched;
  final bool isCompleted;

  WatchProgressModel({
    required this.contentId,
    required this.contentType,
    required this.title,
    this.seriesId,
    this.episodeId,
    this.seasonNumber,
    this.episodeNumber,
    required this.currentPosition,
    required this.totalDuration,
    this.thumbnailUrl,
    required this.lastWatched,
    this.isCompleted = false,
  });

  // Calculate progress percentage
  double get progressPercentage =>
      totalDuration > 0 ? (currentPosition / totalDuration) * 100 : 0;

  // Check if content is worth reminding (opened but not finished)
  bool get shouldRemind =>
      (progressPercentage >= 0 && progressPercentage < 90 && !isCompleted) ||
      (currentPosition == 0 &&
          totalDuration > 0); // Include just opened content

  // Get remaining time in minutes
  int get remainingMinutes => ((totalDuration - currentPosition) / 60).ceil();

  // Get watched time in minutes
  int get watchedMinutes => (currentPosition / 60).ceil();

  factory WatchProgressModel.fromJson(Map<String, dynamic> json) {
    return WatchProgressModel(
      contentId: json['content_id'] ?? '',
      contentType: json['content_type'] ?? '',
      title: json['title'] ?? '',
      seriesId: json['series_id'],
      episodeId: json['episode_id'],
      seasonNumber: json['season_number'],
      episodeNumber: json['episode_number'],
      currentPosition: json['current_position'] ?? 0,
      totalDuration: json['total_duration'] ?? 0,
      thumbnailUrl: json['thumbnail_url'],
      lastWatched: DateTime.parse(json['last_watched']),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'content_type': contentType,
      'title': title,
      'series_id': seriesId,
      'episode_id': episodeId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'current_position': currentPosition,
      'total_duration': totalDuration,
      'thumbnail_url': thumbnailUrl,
      'last_watched': lastWatched.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  WatchProgressModel copyWith({
    String? contentId,
    String? contentType,
    String? title,
    String? seriesId,
    String? episodeId,
    String? seasonNumber,
    String? episodeNumber,
    int? currentPosition,
    int? totalDuration,
    String? thumbnailUrl,
    DateTime? lastWatched,
    bool? isCompleted,
  }) {
    return WatchProgressModel(
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      seriesId: seriesId ?? this.seriesId,
      episodeId: episodeId ?? this.episodeId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lastWatched: lastWatched ?? this.lastWatched,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Generate notification title and body
  String get notificationTitle {
    if (contentType == 'series') {
      return '⏸️ Continue Watching';
    } else {
      return '🎬 Continue Watching';
    }
  }

  String get notificationBody {
    final remaining = remainingMinutes;

    if (currentPosition == 0) {
      // Just opened, not started watching
      if (contentType == 'series' &&
          seasonNumber != null &&
          episodeNumber != null) {
        return 'You opened $title S$seasonNumber E$episodeNumber - Start watching now!';
      } else {
        return 'You opened $title - Start watching now!';
      }
    } else {
      // Partially watched
      if (contentType == 'series' &&
          seasonNumber != null &&
          episodeNumber != null) {
        return 'Resume $title S$seasonNumber E$episodeNumber ($remaining min left)';
      } else {
        return 'Resume $title ($remaining min left)';
      }
    }
  }
}