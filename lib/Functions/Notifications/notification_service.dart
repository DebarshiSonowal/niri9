import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../Models/notification_model.dart';
import '../../Navigation/Navigate.dart';
import '../../Router/routes.dart';
import 'watch_progress_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription = 'This channel is used for important notifications.';

  // Initialize the notification service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _setupFirebaseMessaging();
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel continueWatchingChannel =
          AndroidNotificationChannel(
        'continue_watching_channel',
        'Continue Watching',
        description: 'Reminders to continue watching unfinished content',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(channel);
      await androidImplementation
          ?.createNotificationChannel(continueWatchingChannel);

      debugPrint('✅ Notification channels created');
    }
  }

  // Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Setup Firebase messaging
  Future<void> _setupFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is terminated or in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get FCM token
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      // TODO: Send token to your backend server
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');

    final notification = NotificationModel.fromFirebaseData({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'image_url': message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      ...message.data,
    });
    await _showLocalNotification(message, notification);
  }

  // Show local notification with large image support
  Future<void> _showLocalNotification(
    RemoteMessage message,
    NotificationModel notification,
  ) async {
    try {
      String? bigPicturePath;

      // Download and save large image if provided
      if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
        bigPicturePath = await _downloadAndSaveImage(notification.imageUrl!);
      }

      // Prepare notification payload
      final payload = jsonEncode({
        'action_type': notification.action.toString(),
        'data': message.data,
      });

      // Android notification details with big picture
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        largeIcon: bigPicturePath != null
            ? FilePathAndroidBitmap(bigPicturePath)
            : null,
        styleInformation: bigPicturePath != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(bigPicturePath),
                contentTitle: notification.title,
                summaryText: notification.body,
                largeIcon: FilePathAndroidBitmap(bigPicturePath),
              )
            : BigTextStyleInformation(
                notification.body ?? '',
                contentTitle: notification.title,
              ),
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Download and save image for notification
  Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory appDir = await getTemporaryDirectory();
        final String fileName =
            'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${appDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error downloading notification image: $e');
    }
    return null;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Check if it's a continue watching notification
    if (response.payload != null &&
        response.payload!.contains('continue_watching')) {
      WatchProgressService.handleContinueWatchingTap(response.payload!);
    } else {
      _processNotificationAction(response.payload);
    }
  }

  // Handle Firebase notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final payload = jsonEncode({
      'action_type': message.data['action_type'] ?? '',
      'data': message.data,
    });

    _processNotificationAction(payload);
  }

  // Process notification action and navigate accordingly
  void _processNotificationAction(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final actionType =
          NotificationAction.fromString(data['action_type'] ?? '');
      final actionData = data['data'] as Map<String, dynamic>? ?? {};

      switch (actionType) {
        case NotificationAction.movie:
          _navigateToMovie(actionData);
          break;
        case NotificationAction.subscription:
          _navigateToSubscription();
          break;
        case NotificationAction.screen:
          _navigateToScreen(actionData);
          break;
        case NotificationAction.none:
          break;
      }
    } catch (e) {
      debugPrint('Error processing notification action: $e');
    }
  }

  // Navigate to movie screen
  void _navigateToMovie(Map<String, dynamic> data) {
    final movieId = data['movie_id']?.toString();
    final movieSlug = data['movie_slug']?.toString();

    if (movieId != null || movieSlug != null) {
      // Navigate to watch screen with movie data
      Navigation.instance.navigate(
        Routes.watchScreen,
        args: {
          'movie_id': movieId,
          'movie_slug': movieSlug,
        },
      );
    }
  }

  // Navigate to subscription screen
  void _navigateToSubscription() {
    Navigation.instance.navigate(Routes.subscriptionScreen);
  }

  // Navigate to custom screen
  void _navigateToScreen(Map<String, dynamic> data) {
    final screenRoute = data['screen_route']?.toString();
    final arguments = data['screen_arguments'] as Map<String, dynamic>?;

    if (screenRoute != null) {
      Navigation.instance.navigate(screenRoute, args: arguments);
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message here if needed
}