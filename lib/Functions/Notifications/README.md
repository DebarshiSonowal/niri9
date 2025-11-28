# Firebase Push Notifications Implementation

This implementation provides Firebase push notifications with large image support and action-based
navigation for the NIRI9 app.

## Features

- ✅ Firebase Cloud Messaging (FCM) integration
- ✅ Large image notifications (Big Picture Style)
- ✅ Action-based navigation (Movie, Subscription, Custom Screen)
- ✅ Background and foreground message handling
- ✅ Topic subscription management
- ✅ Cross-platform support (Android/iOS)

## Files Structure

```
lib/Functions/Notifications/
├── notification_service.dart     # Main notification service
├── notification_helper.dart      # Helper functions and utilities
├── watch_progress_service.dart   # Watch progress tracking & reminders
├── video_progress_tracker.dart   # Video player integration
└── README.md                     # This documentation

lib/Models/
├── notification_model.dart       # Notification data models
└── watch_progress_model.dart     # Watch progress data models
```

## Setup

### 1. Dependencies Added

```yaml
dependencies:
  firebase_messaging: ^15.2.4
  flutter_local_notifications: ^19.4.0
  http: ^1.2.2
  path_provider: ^2.1.5
```

### 2. Android Configuration

- Added notification permissions in `AndroidManifest.xml`
- Added Firebase Messaging dependency in `build.gradle.kts`
- Configured notification channels (including continue watching)

### 3. Initialization

The services are automatically initialized in `main.dart`:

```dart
await NotificationService().initialize();
await WatchProgressService().initialize();
```

## Watch Progress & Reminders System

### How It Works

1. **Progress Tracking**: Automatically saves watch progress every 10 seconds
2. **Smart Reminders**: Sends notification 10 seconds after app reopens (once per day)
3. **Auto-Resume**: Clicking notification opens video at exact position left off
4. **Intelligent Filtering**: Only reminds for content watched 10%-90% (skips just started or nearly
   finished)

### Video Player Integration

```dart
import 'package:niri9/Functions/Notifications/video_progress_tracker.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  VideoProgressTracker? _progressTracker;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    _controller = VideoPlayerController.network('VIDEO_URL');
    await _controller.initialize();

    _progressTracker = _controller.createProgressTracker(
      contentId: 'movie_123', 
      contentType: 'movie', 
      title: 'Avengers: Endgame',
      
      thumbnailUrl: 'https://example.com/poster.jpg',
      resumeFromPosition: widget.resumePosition, 
    );

    _controller.addListener(_onPlayerStateChanged);
    
    setState(() {});
  }

  void _onPlayerStateChanged() {
    if (_controller.value.isPlaying) {
      _progressTracker?.onResume();
    } else {
      _progressTracker?.onPause();
    }
  }

  @override
  void dispose() {
    _progressTracker?.dispose(); 
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
```

### Manual Progress Tracking

```dart
import 'package:niri9/Functions/Notifications/watch_progress_service.dart';
import 'package:niri9/Models/watch_progress_model.dart';

final progress = WatchProgressModel(
  contentId: 'movie_123',
  contentType: 'movie',
  title: 'The Dark Knight',
  currentPosition: 3600, 
  totalDuration: 9000, 
  thumbnailUrl: 'https://example.com/poster.jpg',
  lastWatched: DateTime.now(),
);

await WatchProgressService().saveWatchProgress(progress);

await WatchProgressService().markAsCompleted('movie_123');

final unfinished = WatchProgressService().getUnfinishedContent();
```

### Handling Continue Watching Navigation

```dart
class WatchScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const WatchScreen({Key? key, this.arguments}) : super(key: key);
  
  @override
  _WatchScreenState createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  @override
  void initState() {
    super.initState();
    
    if (widget.arguments != null) {
      final args = widget.arguments!;
      final shouldAutoResume = args['auto_resume'] == true;
      final resumePosition = args['resume_position'] as int?;
      
      if (shouldAutoResume && resumePosition != null) {
        _initializeAndPlayVideo(resumeFromSeconds: resumePosition);
      }
    }
  }
  
  void _initializeAndPlayVideo({int resumeFromSeconds = 0}) {
    _controller = VideoPlayerController.network('VIDEO_URL');
    await _controller.initialize();
    _controller.seekTo(Duration(seconds: resumeFromSeconds));
    await _controller.play();
  }
}
```

## Usage

### Basic Usage

```dart
import 'package:niri9/Functions/Notifications/notification_helper.dart';

// Get FCM token for backend
final token = await NotificationHelper.getToken();

// Subscribe to topics
await NotificationHelper.subscribeToTopic('new_movies');
await NotificationHelper.subscribeToUserTopics('user123');

// Subscribe to genres
await NotificationHelper.subscribeToGenres(['action', 'drama', 'comedy']);
```

### Backend Integration

#### 1. Send to Specific User

```json
{
  "to": "FCM_TOKEN_HERE",
  "data": {
    "action_type": "movie",
    "movie_id": "123",
    "movie_slug": "avengers-endgame",
    "title": "New Movie Available!",
    "body": "Check out the latest Avengers movie",
    "image_url": "https://example.com/movie-poster.jpg"
  },
  "notification": {
    "title": "New Movie Available!",
    "body": "Check out the latest Avengers movie",
    "image": "https://example.com/movie-poster.jpg"
  }
}
```

#### 2. Send to Topic

```json
{
  "to": "/topics/all_users",
  "data": {
    "action_type": "subscription",
    "title": "Special Offer!",
    "body": "Get 50% off on premium subscription",
    "image_url": "https://example.com/offer-banner.jpg"
  },
  "notification": {
    "title": "Special Offer!",
    "body": "Get 50% off on premium subscription",
    "image": "https://example.com/offer-banner.jpg"
  }
}
```

#### 3. Navigate to Custom Screen

```json
{
  "to": "FCM_TOKEN_HERE",
  "data": {
    "action_type": "screen",
    "screen_route": "/profile",
    "screen_arguments": "{\"tab\": \"settings\"}",
    "title": "Profile Updated",
    "body": "Your profile has been successfully updated"
  },
  "notification": {
    "title": "Profile Updated",
    "body": "Your profile has been successfully updated"
  }
}
```

## Local Reminder Examples

The system automatically generates these local notifications:

### Movie Reminder

Continue Watching
Resume The Dark Knight (45 min left)

### Series Episode Reminder

Continue Watching
Resume Breaking Bad S3 E7 (28 min left)

### When Reminders Are Sent

- 10 seconds after app reopens
- Only once per day per user
- Only for content watched 10%-90%
- Shows most recently watched unfinished content
- Includes remaining time estimate

### What Happens When User Taps Reminder

1. Opens watch screen automatically
2. Loads the exact movie/episode
3. Resumes from exact second where left off
4. Starts playing (configurable)

## Notification Actions

### Supported Actions

1. **Movie Action** (`action_type: "movie"`)
   - Navigates to watch screen
   - Required data: `movie_id` or `movie_slug`

2. **Subscription Action** (`action_type: "subscription"`)
   - Navigates to subscription screen
   - No additional data required

3. **Screen Action** (`action_type: "screen"`)
   - Navigates to custom screen
   - Required data: `screen_route`
   - Optional: `screen_arguments` (JSON string)

4. **Continue Watching Action** (`action_type: "continue_watching"`)

### Adding New Actions

1. Add new action to `NotificationAction` enum in `notification_model.dart`:

```dart
enum NotificationAction {
  movie,
  subscription,
  screen,
  watchlist, // New action
  none;
}
```

2. Add handling in `NotificationService._processNotificationAction()`:

```dart
case NotificationAction.watchlist:
  _navigateToWatchlist(actionData);
  break;
```

3. Implement navigation method:

```dart
void _navigateToWatchlist(Map<String, dynamic> data) {
  Navigation.instance.navigate(Routes.watchlistScreen);
}
```

## Testing Notifications

### Testing Watch Progress Reminders

1. **Setup Test Content**:

2. **Simulate Progress**:
   - Play video for 2+ minutes (to reach 10% threshold)
   - Pause or exit video
   - Close and reopen app
   - Wait 10 seconds → notification should appear

3. **Test Notification Tap**:
   - Tap notification → should open watch screen
   - Video should auto-resume from saved position

### Using Firebase Console
1. Go to Firebase Console → Your Project → Cloud Messaging
2. Click "Send your first message"
3. Add title, text, and image
4. In "Additional options" → "Custom data", add:

```json
{
   "action_type": "movie",
   "movie_id": "123"
}
```

### Using curl
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN",
    "data": {
      "action_type": "movie",
      "movie_id": "123",
      "title": "New Movie!",
      "body": "Check out this awesome movie",
      "image_url": "https://example.com/poster.jpg"
    }
  }'
```

## Troubleshooting

### Common Issues

1. **Notifications not received**
    - Check if permissions are granted
    - Verify FCM token is valid
    - Ensure app is properly configured with Firebase

2. **Images not showing**
    - Verify image URL is accessible
    - Check image format (JPG/PNG recommended)
    - Ensure device has internet connection

3. **Navigation not working**
    - Verify route names in `Routes` class
    - Check if required data is provided
    - Ensure app is properly initialized

4. **Reminders not appearing**
   - Ensure 10+ seconds have passed since app reopen
   - Check if content meets 10%-90% threshold
   - Verify notification permissions are granted
   - Check if reminder was already sent today

### Debug Commands

```dart
// Enable debug logging
debugPrint('FCM Token: ${await NotificationHelper.getToken()}');

// Check subscription status
await NotificationHelper.subscribeToTopic('debug');
```

## Best Practices

1. **Token Management**
    - Send FCM tokens to your backend after login
    - Refresh tokens when they change
    - Remove tokens after logout

2. **Topic Subscriptions**
    - Subscribe to relevant topics only
    - Unsubscribe when not needed
    - Use descriptive topic names

3. **Image Optimization**
    - Use compressed images (< 1MB recommended)
    - Provide fallback for missing images
    - Consider different screen densities

4. **Action Design**
    - Keep action data minimal
    - Handle edge cases gracefully
    - Provide user feedback for actions

## Security Considerations

- Never include sensitive data in notifications
- Validate all incoming notification data
- Use HTTPS for image URLs
- Implement proper authentication for backend APIs
- Encrypt sensitive progress data if needed

## Performance Tips

- Cache downloaded notification images
- Limit concurrent image downloads
- Clean up old notification images periodically
- Use background processing for heavy operations