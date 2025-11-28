import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/watch_progress_model.dart';
import '../../Navigation/Navigate.dart';
import '../../Router/routes.dart';
import 'notification_service.dart';

class WatchProgressService {
  static final WatchProgressService _instance = WatchProgressService
      ._internal();

  factory WatchProgressService() => _instance;

  WatchProgressService._internal();

  static const String _watchProgressKey = 'watch_progress_data';
  static const String _appOpenTimeKey = 'app_open_time';
  static const String _reminderSentKey = 'reminder_sent_today';

  Timer? _reminderTimer;
  final List<WatchProgressModel> _watchProgress = [];

  // Initialize the service
  Future<void> initialize() async {
    debugPrint('🚀 WatchProgressService initialize called');

    await _loadWatchProgress();
    _scheduleAppReopenReminder();

    debugPrint('✅ WatchProgressService initialized');
  }

  // Save watch progress when user pauses/exits video
  Future<void> saveWatchProgress(WatchProgressModel progress) async {
    try {
      debugPrint('💾 Saving watch progress: ${progress.title}');
      debugPrint(
          '   Progress: ${progress.progressPercentage.toStringAsFixed(1)}%');
      debugPrint('   Should remind: ${progress.shouldRemind}');
      debugPrint(
          '   Position: ${progress.currentPosition}s / ${progress.totalDuration}s');

      // Remove existing progress for the same content
      _watchProgress.removeWhere((p) => p.contentId == progress.contentId);

      // Add new progress if it's worth tracking
      if (progress.shouldRemind) {
        _watchProgress.add(progress);
        debugPrint(
            '✅ Progress added to reminder list (total: ${_watchProgress.length})');
      } else {
        debugPrint('❌ Progress not added - doesn\'t meet reminder criteria');
      }

      await _saveWatchProgressToStorage();
      debugPrint('💾 Progress saved to storage');
    } catch (e) {
      debugPrint('❌ Error saving watch progress: $e');
    }
  }

  // Mark content as completed
  Future<void> markAsCompleted(String contentId) async {
    try {
      final index = _watchProgress.indexWhere((p) => p.contentId == contentId);
      if (index != -1) {
        _watchProgress[index] =
            _watchProgress[index].copyWith(isCompleted: true);
        await _saveWatchProgressToStorage();
        debugPrint('Marked content as completed: $contentId');
      }
    } catch (e) {
      debugPrint('Error marking content as completed: $e');
    }
  }

  // Remove watch progress (when user manually removes from continue watching)
  Future<void> removeWatchProgress(String contentId) async {
    try {
      _watchProgress.removeWhere((p) => p.contentId == contentId);
      await _saveWatchProgressToStorage();
      debugPrint('Removed watch progress: $contentId');
    } catch (e) {
      debugPrint('Error removing watch progress: $e');
    }
  }

  // Get all unfinished content
  List<WatchProgressModel> getUnfinishedContent() {
    return _watchProgress.where((p) => p.shouldRemind).toList()
      ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
  }

  // Get most recent unfinished content
  WatchProgressModel? getMostRecentUnfinished() {
    final unfinished = getUnfinishedContent();
    return unfinished.isNotEmpty ? unfinished.first : null;
  } 

  // Schedule reminder after app reopens
  void _scheduleAppReopenReminder() {
    _reminderTimer?.cancel();

    // Check if we should send reminder after 10 seconds
    _reminderTimer = Timer(const Duration(seconds: 10), () async {
      await _checkAndSendReminder();
    });

    debugPrint('Scheduled watch progress reminder for 10 seconds');
  }

  // Check and send reminder notification
  Future<void> _checkAndSendReminder() async {
    debugPrint('🔍 _checkAndSendReminder called');

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastReminderDate = prefs.getString(_reminderSentKey);

      debugPrint('📅 Today: $today, Last reminder: $lastReminderDate');

      // Don't send more than one reminder per day
      if (lastReminderDate == today) {
        debugPrint('⏭️ Reminder already sent today, skipping');
        return;
      }

      debugPrint('📊 Checking for unfinished content...');
      final mostRecent = getMostRecentUnfinished();

      if (mostRecent == null) {
        debugPrint('❌ No unfinished content found');
        debugPrint('📋 Available progress items: ${_watchProgress.length}');
        for (var progress in _watchProgress) {
          debugPrint(
              '   - ${progress.title}: ${progress.progressPercentage.toStringAsFixed(1)}% (shouldRemind: ${progress.shouldRemind})');
        }
        return;
      }

      debugPrint(
          '✅ Found content to remind: ${mostRecent.title} at ${mostRecent.progressPercentage.toStringAsFixed(1)}%');
      debugPrint('🔔 Sending notification...');

      await _sendContinueWatchingNotification(mostRecent);
      await prefs.setString(_reminderSentKey, today);
      debugPrint('✅ Reminder sent and logged for: ${mostRecent.title}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _checkAndSendReminder: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
  }

  // Send local notification for continue watching
  Future<void> _sendContinueWatchingNotification(
      WatchProgressModel progress) async {
    debugPrint(
        '🔔 _sendContinueWatchingNotification called for: ${progress.title}');

    try {
      final notificationService = NotificationService();
      final flutterLocalNotifications = FlutterLocalNotificationsPlugin();

      // Create notification payload
      final payload = jsonEncode({
        'action_type': 'continue_watching',
        'content_id': progress.contentId,
        'content_type': progress.contentType,
        'series_id': progress.seriesId,
        'episode_id': progress.episodeId,
        'current_position': progress.currentPosition,
        'title': progress.title,
        'season_number': progress.seasonNumber,
        'episode_number': progress.episodeNumber,
      });

      debugPrint('📱 Notification payload created');
      debugPrint('🎯 Title: ${progress.notificationTitle}');
      debugPrint('📝 Body: ${progress.notificationBody}');

      // Download thumbnail if available
      String? thumbnailPath;
      if (progress.thumbnailUrl != null) {
        debugPrint('🖼️ Thumbnail URL available: ${progress.thumbnailUrl}');
        // You can reuse the image download method from NotificationService
        // or implement a simpler version here
      }

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'continue_watching_channel',
        'Continue Watching',
        channelDescription: 'Reminders to continue watching unfinished content',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: 'ic_play_arrow',
        // You can add a custom play icon
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          progress.notificationBody,
          contentTitle: progress.notificationTitle,
        ),
      );

      debugPrint('📋 Android notification details configured');

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'CONTINUE_WATCHING',
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      debugPrint('📲 Attempting to show notification...');

      await flutterLocalNotifications.show(
        progress.contentId.hashCode,
        progress.notificationTitle,
        progress.notificationBody,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Notification.show() called successfully');
      debugPrint('🆔 Notification ID: ${progress.contentId.hashCode}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending continue watching notification: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
  }

  // Handle notification tap (integrate with existing notification service)
  static void handleContinueWatchingTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;

      if (data['action_type'] == 'continue_watching') {
        final contentType = data['content_type'] as String;
        final currentPosition = data['current_position'] as int;
        final contentId = data['content_id'] as String;
        final title = data['title'] as String;

        debugPrint('🎬 Continue watching notification tapped');
        debugPrint('📺 Content: $title');
        debugPrint(
            '⏱️ Resume at: ${currentPosition}s (${(currentPosition / 60).toStringAsFixed(1)} min)');

        Map<String, dynamic> args = {
          'auto_resume': true,
          'resume_position': currentPosition,
          'from_notification': true,
        };

        if (contentType == 'movie') {
          args['movie_id'] = contentId;
          debugPrint(
              '🎭 Navigating to movie: $contentId at ${currentPosition}s');
        } else if (contentType == 'series') {
          final seriesId = data['series_id'] as String?;
          final episodeId = data['episode_id'] as String?;

          args['series_id'] = seriesId;
          args['episode_id'] = episodeId;

          debugPrint(
              '📺 Navigating to series: $seriesId, episode: $episodeId at ${currentPosition}s');

          // Additional episode info for better navigation
          if (data.containsKey('season_number')) {
            args['season_number'] = data['season_number'];
          }
          if (data.containsKey('episode_number')) {
            args['episode_number'] = data['episode_number'];
          }
        }

        Navigation.instance.navigate(Routes.watchScreen, args: args);
        debugPrint('✅ Navigation initiated with resume args');
      }
    } catch (e) {
      debugPrint('❌ Error handling continue watching tap: $e');
    }
  }

  // Load watch progress from storage
  Future<void> _loadWatchProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getStringList(_watchProgressKey) ?? [];

      _watchProgress.clear();
      for (final json in progressJson) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        final progress = WatchProgressModel.fromJson(data);

        // Only keep recent progress (last 30 days)
        if (DateTime
            .now()
            .difference(progress.lastWatched)
            .inDays <= 30) {
          _watchProgress.add(progress);
        }
      }

      debugPrint('Loaded ${_watchProgress.length} watch progress items');
    } catch (e) {
      debugPrint('Error loading watch progress: $e');
    }
  }

  // Save watch progress to storage
  Future<void> _saveWatchProgressToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = _watchProgress
          .map((p) => jsonEncode(p.toJson()))
          .toList();
      await prefs.setStringList(_watchProgressKey, progressJson);
    } catch (e) {
      debugPrint('Error saving watch progress to storage: $e');
    }
  }

  // Record app open time (call this in main.dart or splash screen)
  Future<void> recordAppOpen() async {
    debugPrint('📱 recordAppOpen called');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appOpenTimeKey, DateTime.now().toIso8601String());

      debugPrint('⏰ App open time recorded');

      // Schedule reminder for 10 seconds from now
      _scheduleAppReopenReminder();
    } catch (e) {
      debugPrint('❌ Error recording app open: $e');
    }
  }

  // Clean up old progress data
  Future<void> cleanupOldProgress() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      _watchProgress.removeWhere((p) => p.lastWatched.isBefore(cutoffDate));
      await _saveWatchProgressToStorage();
      debugPrint('Cleaned up old watch progress data');
    } catch (e) {
      debugPrint('Error cleaning up progress: $e');
    }
  }

  // Dispose timer
  void dispose() {
    _reminderTimer?.cancel();
  }

  // Track when user opens content (even at 0% progress)
  Future<void> trackContentOpened({
    required String contentId,
    required String contentType,
    required String title,
    String? seriesId,
    String? episodeId,
    String? seasonNumber,
    String? episodeNumber,
    String? thumbnailUrl,
    int estimatedDuration = 5400, // Default 90 minutes
  }) async {
    debugPrint('👁️ Tracking content opened: $title');

    try {
      final progress = WatchProgressModel(
        contentId: contentId,
        contentType: contentType,
        title: title, 
        seriesId: seriesId,
        episodeId: episodeId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        currentPosition: 0,
        // Just opened
        totalDuration: estimatedDuration,
        thumbnailUrl: thumbnailUrl,
        lastWatched: DateTime.now(),
      );

      await saveWatchProgress(progress);
      debugPrint('✅ Content opening tracked for reminders');
    } catch (e) {
      debugPrint('❌ Error tracking content opened: $e');
    }
  }

  // Test method to add sample progress data for debugging
  Future<void> addTestProgress() async {
    debugPrint('🧪 Adding test progress data');

    // Test case 1: Just opened content (0% progress)
    final justOpenedProgress = WatchProgressModel(
      contentId: 'test_opened_123',
      contentType: 'movie',
      title: 'Just Opened - Spider-Man',
      currentPosition: 0,
      // Not started
      totalDuration: 7200,
      // 2 hours
      thumbnailUrl: 'https://example.com/spiderman-poster.jpg',
      lastWatched: DateTime.now(),
    );

    await saveWatchProgress(justOpenedProgress);
    debugPrint(
        '✅ Just opened progress added: ${justOpenedProgress.progressPercentage.toStringAsFixed(1)}%');

    // Test case 2: Partially watched movie
    final partiallyWatchedProgress = WatchProgressModel(
      contentId: 'test_movie_456',
      contentType: 'movie',
      title: 'Partially Watched - Avengers Endgame',
      currentPosition: 1800,
      // 30 minutes
      totalDuration: 10800,
      // 3 hours
      thumbnailUrl: 'https://example.com/avengers-poster.jpg',
      lastWatched: DateTime.now(),
    );

    await saveWatchProgress(partiallyWatchedProgress);
    debugPrint(
        '✅ Partially watched progress added: ${partiallyWatchedProgress.progressPercentage.toStringAsFixed(1)}%');

    // Test case 3: Series episode (exact episode tracking)
    final seriesEpisodeProgress = WatchProgressModel(
      contentId: 'episode_789',
      contentType: 'series',
      title: 'Breaking Bad',
      seriesId: 'series_100',
      episodeId: 'episode_789',
      seasonNumber: '3',
      episodeNumber: '7',
      currentPosition: 1350,
      // 22.5 minutes into episode
      totalDuration: 2700,
      // 45 minute episode
      thumbnailUrl: 'https://example.com/breaking-bad-poster.jpg',
      lastWatched: DateTime.now(),
    );

    await saveWatchProgress(seriesEpisodeProgress);
    debugPrint(
        '✅ Series episode progress added: ${seriesEpisodeProgress.title} S${seriesEpisodeProgress.seasonNumber}E${seriesEpisodeProgress.episodeNumber} at ${seriesEpisodeProgress.progressPercentage.toStringAsFixed(1)}%');
  }

  // Force send reminder for testing (bypasses daily limit)
  Future<void> forceSendTestReminder() async {
    debugPrint('🧪 Force sending test reminder');

    final mostRecent = getMostRecentUnfinished();
    if (mostRecent != null) {
      debugPrint('📤 Sending test reminder for: ${mostRecent.title}');
      await _sendContinueWatchingNotification(mostRecent);
      debugPrint('✅ Test reminder sent');
    } else {
      debugPrint('❌ No content available for test reminder');
    }
  }
}