import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  // Initialize notifications (call this in main.dart)
  static Future<void> initialize() async {
    await _notificationService.initialize();
  }

  // Get FCM token (useful for sending to your backend)
  static Future<String?> getToken() async {
    final token = await _notificationService.getToken();
    debugPrint('FCM Token for backend: $token');
    return token;
  }

  // Subscribe to notification topics
  static Future<void> subscribeToUserTopics(String userId) async {
    // Subscribe to user-specific topics
    await _notificationService.subscribeToTopic('user_$userId');
    await _notificationService.subscribeToTopic('all_users');

    debugPrint('Subscribed to notification topics for user: $userId');
  }

  // Subscribe to movie genre topics
  static Future<void> subscribeToGenres(List<String> genres) async {
    for (final genre in genres) {
      await _notificationService.subscribeToTopic(
          'genre_${genre.toLowerCase()}');
    }
    debugPrint('Subscribed to genres: $genres');
  }

  // Unsubscribe when user logs out
  static Future<void> unsubscribeFromUserTopics(String userId) async {
    await _notificationService.unsubscribeFromTopic('user_$userId');
    debugPrint('Unsubscribed from user topics for: $userId');
  }

  // General subscription management
  static Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }
}