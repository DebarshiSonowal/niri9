# 🎬 Watch Screen Integration for Immediate Reminders

## 📱 Integration Steps

### 1. **Track Content Opening (Call this when screen opens)**

Add this to your watch screen's `initState()` or when the user selects content:

```dart
import 'package:niri9/Functions/Notifications/watch_progress_service.dart';

class WatchScreen extends StatefulWidget {
  final String? movieId;
  final String? movieTitle;
  
  @override
  _WatchScreenState createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  @override
  void initState() {
    super.initState();
    
    // 🎯 TRACK CONTENT OPENING IMMEDIATELY
    _trackContentOpened();
    
    // Then initialize your video player...
    _initializePlayer();
  }

  // Track that user opened this content
  Future<void> _trackContentOpened() async {
    if (widget.movieId != null && widget.movieTitle != null) {
      await WatchProgressService().trackContentOpened(
        contentId: widget.movieId!,
        contentType: 'movie', // or 'series'
        title: widget.movieTitle!,
        // For series, also include:
        // seriesId: widget.seriesId,
        // episodeId: widget.episodeId,
        // seasonNumber: widget.seasonNumber,
        // episodeNumber: widget.episodeNumber,
        thumbnailUrl: 'https://example.com/poster.jpg',
        estimatedDuration: 7200, // 2 hours in seconds
      );
    }
  }
}
```

### 2. **Update Progress During Playback**

Keep your existing video progress tracking:

```dart
// Your existing VideoProgressTracker will update the progress
_progressTracker = _controller.createProgressTracker(
  contentId: widget.movieId!,
  contentType: 'movie',
  title: widget.movieTitle!,
  // This will override the 0% progress with actual progress
);
```

## 🔄 **Complete Flow:**

### **Scenario 1: User just opens movie and leaves**

1. ✅ User taps movie → Watch screen opens
2. ✅ `trackContentOpened()` saves 0% progress
3. ✅ User presses back or minimizes app
4. ✅ After 10 seconds → Gets notification: "You opened Spider-Man - Start watching now!"

### **Scenario 2: User watches partially then leaves**

1. ✅ User taps movie → Watch screen opens
2. ✅ `trackContentOpened()` saves 0% progress
3. ✅ User starts watching → `VideoProgressTracker` updates progress to 25%
4. ✅ User pauses and leaves
5. ✅ After 10 seconds → Gets notification: "Resume Spider-Man (90 min left)"

## 🧪 **Testing with Debug Widget**

The debug widget now creates both test cases:

```dart
// Test Case 1: Just opened (0% progress)
"Just Opened - Spider-Man" → "You opened Just Opened - Spider-Man - Start watching now!"

// Test Case 2: Partially watched (16.7% progress)  
"Partially Watched - Avengers Endgame" → "Resume Partially Watched - Avengers Endgame (150 min left)"
```

## 📍 **Where to Add Content Tracking:**

### **Movie Detail Screen**

```dart
// When user taps "Play" or "Watch Now"
await WatchProgressService().trackContentOpened(
  contentId: movie.id.toString(),
  contentType: 'movie',
  title: movie.title ?? '',
  thumbnailUrl: movie.posterPic,
  estimatedDuration: movie.duration ?? 7200,
);
```

### **Series Episode Screen**

```dart
// When user selects an episode
await WatchProgressService().trackContentOpened(
  contentId: episode.id.toString(),
  contentType: 'series',
  title: series.title ?? '',
  seriesId: series.id.toString(),
  episodeId: episode.id.toString(),
  seasonNumber: episode.seasonNumber?.toString(),
  episodeNumber: episode.episodeNumber?.toString(),
  thumbnailUrl: episode.thumbnailUrl,
  estimatedDuration: episode.duration ?? 2700, // 45 min default for episodes
);
```

## 🎯 **Key Benefits:**

- ✅ **Immediate Tracking**: Content is tracked the moment user opens it
- ✅ **No Lost Engagement**: Even if user just browses and leaves, they get reminded
- ✅ **Smart Messages**: Different messages for "just opened" vs "partially watched"
- ✅ **No Double Tracking**: VideoProgressTracker will override 0% with actual progress

## 🔧 **Integration Checklist:**

- [ ] Add `trackContentOpened()` call in watch screen `initState()`
- [ ] Keep existing `VideoProgressTracker` for actual playback progress
- [ ] Test with debug widget to verify notifications work
- [ ] Check notification permissions are enabled
- [ ] Verify both 0% and partial progress notifications work

**Result: Users get reminders even if they just opened content and left immediately!** 🎉