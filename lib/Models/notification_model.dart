class NotificationModel {
  final String? title;
  final String? body;
  final String? imageUrl;
  final NotificationAction action;
  final Map<String, dynamic> data;
  final DateTime receivedAt;

  NotificationModel({
    this.title,
    this.body,
    this.imageUrl,
    required this.action,
    required this.data,
    required this.receivedAt,
  });

  factory NotificationModel.fromFirebaseData(Map<String, dynamic> data) {
    return NotificationModel(
      title: data['title'],
      body: data['body'],
      imageUrl: data['image_url'] ?? data['image'],
      action: NotificationAction.fromString(data['action_type'] ?? ''),
      data: data,
      receivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'action_type': action.toString(),
      'data': data,
      'received_at': receivedAt.toIso8601String(),
    };
  }
}

enum NotificationAction {
  movie,
  subscription,
  screen,
  none;

  static NotificationAction fromString(String value) {
    switch (value.toLowerCase()) {
      case 'movie':
        return NotificationAction.movie;
      case 'subscription':
        return NotificationAction.subscription;
      case 'screen':
        return NotificationAction.screen;
      default:
        return NotificationAction.none;
    }
  }

  @override
  String toString() {
    return name;
  }
}

class NotificationActionData {
  final String? movieId;
  final String? movieSlug;
  final String? screenRoute;
  final Map<String, dynamic>? screenArguments;

  NotificationActionData({
    this.movieId,
    this.movieSlug,
    this.screenRoute,
    this.screenArguments,
  });

  factory NotificationActionData.fromMap(Map<String, dynamic> data) {
    return NotificationActionData(
      movieId: data['movie_id']?.toString(),
      movieSlug: data['movie_slug'],
      screenRoute: data['screen_route'],
      screenArguments: data['screen_arguments'] is Map
          ? Map<String, dynamic>.from(data['screen_arguments'])
          : null,
    );
  }
}