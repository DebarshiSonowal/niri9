# Integration Example: Adding Watch Progress Tracking

This example shows how to integrate the watch progress tracking system into your existing video
player.

## Before Integration (Existing Code)

```dart
// Your existing video player widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String movieId;
  final String title;
  
  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.movieId, 
    required this.title,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
```

## After Integration (With Progress Tracking)

```dart
// Updated video player widget with progress tracking
import 'package:niri9/Functions/Notifications/video_progress_tracker.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String movieId;
  final String title;
  final String contentType; // 'movie' or 'series'
  final String? seriesId;
  final String? episodeId;
  final String? seasonNumber;
  final String? episodeNumber;
  final String? thumbnailUrl;
  final int? resumeFromPosition; // From notification args
  
  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.movieId,
    required this.title,
    this.contentType = 'movie',
    this.seriesId,
    this.episodeId,
    this.seasonNumber,
    this.episodeNumber,
    this.thumbnailUrl,
    this.resumeFromPosition,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> 
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  VideoProgressTracker? _progressTracker;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  void _initializePlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize();
    
    // 🆕 Initialize progress tracker
    _progressTracker = _controller.createProgressTracker(
      contentId: widget.movieId,
      contentType: widget.contentType,
      title: widget.title,
      seriesId: widget.seriesId,
      episodeId: widget.episodeId,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
      thumbnailUrl: widget.thumbnailUrl,
      resumeFromPosition: widget.resumeFromPosition,
    );
    
    // 🆕 Listen to player state changes
    _controller.addListener(_onPlayerStateChanged);
    
    setState(() {
      _isInitialized = true;
    });
    
    // Auto-play if resuming from notification
    if (widget.resumeFromPosition != null) {
      _controller.play();
    }
  }

  // 🆕 Handle player state changes
  void _onPlayerStateChanged() {
    if (_controller.value.isPlaying) {
      _progressTracker?.onResume();
    } else if (!_controller.value.isPlaying && 
               _controller.value.position.inSeconds > 0) {
      _progressTracker?.onPause();
    }
    
    // Check if video completed
    if (_controller.value.position >= _controller.value.duration) {
      _progressTracker?.onComplete();
    }
  }

  // 🆕 Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Save progress when app goes to background
        _progressTracker?.saveCurrentProgress();
        break;
      case AppLifecycleState.resumed:
        // Could resume tracking if needed
        break;
      default:
        break;
    }
  }

  // 🆕 Handle manual seek
  void _onSeek(Duration position) {
    _controller.seekTo(position);
    _progressTracker?.onSeek(position);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onPlayerStateChanged);
    
    // 🆕 IMPORTANT: Dispose progress tracker to save final progress
    _progressTracker?.dispose();
    
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // 🆕 Add progress indicator in app bar
        bottom: _isInitialized ? PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: EdgeInsets.all(0),
          ),
        ) : null,
      ),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                // 🆕 Add custom controls with seek functionality
                _buildCustomControls(),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  // 🆕 Custom controls with progress tracking
  Widget _buildCustomControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.replay_10),
            onPressed: () {
              final position = _controller.value.position - Duration(seconds: 10);
              _onSeek(position > Duration.zero ? position : Duration.zero);
            },
          ),
          IconButton(
            icon: Icon(_controller.value.isPlaying 
                ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.forward_10),
            onPressed: () {
              final position = _controller.value.position + Duration(seconds: 10);
              final duration = _controller.value.duration;
              _onSeek(position < duration ? position : duration);
            },
          ),
          // 🆕 Progress percentage display
          if (_progressTracker != null)
            Text(
              '${_progressTracker!.getCurrentProgressPercentage().toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
```

## Usage in Your App

### 1. From Normal Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoPlayerWidget(
      videoUrl: 'https://example.com/video.mp4',
      movieId: 'movie_123',
      title: 'Avengers: Endgame',
      contentType: 'movie',
      thumbnailUrl: 'https://example.com/poster.jpg',
    ),
  ),
);
```

### 2. From Continue Watching Notification

```dart
// In your router/navigation handler
class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/watch':
        final args = settings.arguments as Map<String, dynamic>?;
        
        return MaterialPageRoute(
          builder: (context) => VideoPlayerWidget(
            videoUrl: _getVideoUrl(args?['movie_id']),
            movieId: args?['movie_id'] ?? '',
            title: _getMovieTitle(args?['movie_id']),
            contentType: 'movie',
            resumeFromPosition: args?['resume_position'], // 🆕 Auto-resume
            thumbnailUrl: _getMovieThumbnail(args?['movie_id']),
          ),
        );
        
      // ... other routes
    }
  }
}
```

### 3. For Series Episodes

```dart
VideoPlayerWidget(
  videoUrl: 'https://example.com/episode.mp4',
  movieId: 'episode_456',
  title: 'Breaking Bad',
  contentType: 'series', // 🆕
  seriesId: 'series_789', // 🆕
  episodeId: 'episode_456', // 🆕
  seasonNumber: '3', // 🆕
  episodeNumber: '7', // 🆕
  thumbnailUrl: 'https://example.com/episode-thumb.jpg',
)
```

## Testing the Integration

### 1. Test Basic Progress Saving

1. Play a video for 2+ minutes
2. Pause or exit the video
3. Check debug logs for "Saved watch progress" message

### 2. Test Reminder Notification

1. Play video, then exit before completion
2. Close the app completely
3. Reopen the app
4. Wait 2 minutes → you should see a reminder notification

### 3. Test Auto-Resume

1. Tap the reminder notification
2. Video should open and start from where you left off
3. Check debug logs for "Resumed video from position" message

## Advanced Customization

### Custom Progress Thresholds

```dart
// In your VideoProgressTracker subclass
class CustomVideoProgressTracker extends VideoProgressTracker {
  @override
  bool get shouldRemind {
    // Custom logic: only remind for content watched 20%-80%
    return progressPercentage >= 20 && progressPercentage < 80 && !isCompleted;
  }
}
```

### Custom Notification Messages

```dart
// In WatchProgressModel
@override
String get notificationBody {
  final remaining = remainingMinutes;
  if (contentType == 'series') {
    return 'Continue $title S$seasonNumber E$episodeNumber\n$remaining minutes remaining';
  } else {
    return 'Resume watching $title\nOnly $remaining minutes left!';
  }
}
```

### Custom Reminder Timing

```dart
// In WatchProgressService
void scheduleCustomReminder(Duration delay) {
  _reminderTimer?.cancel();
  _reminderTimer = Timer(delay, () async {
    await _checkAndSendReminder();
  });
}
```

## Troubleshooting Integration

### Common Issues

1. **Progress not saving**
    - Ensure `dispose()` is called properly
    - Check if `VideoProgressTracker.dispose()` is being called
    - Verify `_onPlayerStateChanged()` is triggered

2. **Notification not appearing**
    - Wait full 2 minutes after app reopen
    - Check if content meets percentage threshold (10%-90%)
    - Verify notification permissions

3. **Auto-resume not working**
    - Check if `resumeFromPosition` argument is passed correctly
    - Verify route handling for notification navigation
    - Ensure video URL is accessible

### Debug Checkers

```dart
// Add to your video player
void _debugProgress() {
  if (_progressTracker != null) {
    final progress = _progressTracker!.getCurrentProgress();
    if (progress != null) {
      print('Current progress: ${progress.progressPercentage.toStringAsFixed(1)}%');
      print('Should remind: ${progress.shouldRemind}');
      print('Position: ${progress.currentPosition}s / ${progress.totalDuration}s');
    }
  }
}

// Call periodically or on button press for testing
```

This integration maintains your existing video player functionality while adding powerful watch
progress tracking and reminder capabilities!