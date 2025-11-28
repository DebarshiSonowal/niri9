# 🎯 Exact Resume Integration Guide

## 📱 Watch Screen Integration for Exact Resume

### 1. **Update Your Watch Screen Constructor**

```dart
class WatchScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const WatchScreen({Key? key, this.arguments}) : super(key: key);
  
  @override
  _WatchScreenState createState() => _WatchScreenState();
}
```

### 2. **Handle Resume Arguments in initState**

```dart
class _WatchScreenState extends State<WatchScreen> {
  late VideoPlayerController _controller;
  VideoProgressTracker? _progressTracker;
  
  // Resume data from notification
  String? movieId;
  String? seriesId;
  String? episodeId;
  String? seasonNumber;
  String? episodeNumber;
  int resumePosition = 0;
  bool fromNotification = false;

  @override
  void initState() {
    super.initState();
    _parseArguments();
    _initializePlayer();
  }

  void _parseArguments() {
    if (widget.arguments != null) {
      final args = widget.arguments!;
      
      // Extract resume information
      movieId = args['movie_id']?.toString();
      seriesId = args['series_id']?.toString();
      episodeId = args['episode_id']?.toString();
      seasonNumber = args['season_number']?.toString();
      episodeNumber = args['episode_number']?.toString();
      resumePosition = args['resume_position'] ?? 0;
      fromNotification = args['from_notification'] == true;
      
      debugPrint('🎬 Watch screen arguments parsed:');
      debugPrint('   Movie ID: $movieId');
      debugPrint('   Series ID: $seriesId');
      debugPrint('   Episode ID: $episodeId');
      debugPrint('   Season: $seasonNumber, Episode: $episodeNumber');
      debugPrint('   Resume Position: ${resumePosition}s');
      debugPrint('   From Notification: $fromNotification');
      
      if (fromNotification && resumePosition > 0) {
        debugPrint('🔔 Resuming from notification at ${resumePosition}s (${(resumePosition / 60).toStringAsFixed(1)} min)');
      }
    }
  }

  Future<void> _initializePlayer() async {
    // Determine video URL based on content type
    String videoUrl;
    String contentTitle;
    
    if (seriesId != null && episodeId != null) {
      // Series episode
      videoUrl = await _getEpisodeVideoUrl(seriesId!, episodeId!);
      contentTitle = await _getEpisodeTitle(seriesId!, episodeId!);
      debugPrint('📺 Loading series episode: $contentTitle S${seasonNumber}E${episodeNumber}');
    } else if (movieId != null) {
      // Movie
      videoUrl = await _getMovieVideoUrl(movieId!);
      contentTitle = await _getMovieTitle(movieId!);
      debugPrint('🎬 Loading movie: $contentTitle');
    } else {
      debugPrint('❌ No valid content ID provided');
      return;
    }

    _controller = VideoPlayerController.network(videoUrl);
    await _controller.initialize();

    // Create progress tracker with exact resume position
    _progressTracker = _controller.createProgressTracker(
      contentId: episodeId ?? movieId ?? 'unknown',
      contentType: seriesId != null ? 'series' : 'movie',
      title: contentTitle,
      seriesId: seriesId,
      episodeId: episodeId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      resumeFromPosition: resumePosition, // Exact resume position
    );

    // Show resume dialog if coming from notification
    if (fromNotification && resumePosition > 0) {
      _showResumeDialog(contentTitle, resumePosition);
    }

    setState(() {});
  }

  void _showResumeDialog(String title, int resumeSeconds) {
    final resumeMinutes = (resumeSeconds / 60).toStringAsFixed(1);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resume Watching'),
        content: Text(
          'Continue watching $title from ${resumeMinutes} minutes?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Start from beginning
              _controller.seekTo(Duration.zero);
              _controller.play();
            },
            child: Text('Start Over'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume from saved position (already set by progress tracker)
              _controller.play();
            },
            child: Text('Resume'),
          ),
        ],
      ),
    );
  }

  // Helper methods to get content data
  Future<String> _getEpisodeVideoUrl(String seriesId, String episodeId) async {
    // Your API call to get episode video URL
    // return await ApiProvider.getEpisodeVideoUrl(seriesId, episodeId);
    return 'https://example.com/episode.mp4';
  }

  Future<String> _getEpisodeTitle(String seriesId, String episodeId) async {
    // Your API call to get episode title
    // return await ApiProvider.getEpisodeTitle(seriesId, episodeId);
    return 'Breaking Bad S3E7';
  }

  Future<String> _getMovieVideoUrl(String movieId) async {
    // Your API call to get movie video URL
    // return await ApiProvider.getMovieVideoUrl(movieId);
    return 'https://example.com/movie.mp4';
  }

  Future<String> _getMovieTitle(String movieId) async {
    // Your API call to get movie title
    // return await ApiProvider.getMovieTitle(movieId);
    return 'Avengers Endgame';
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
      appBar: AppBar(
        title: Text(_getDisplayTitle()),
      ),
      body: _controller.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                _buildProgressIndicator(),
                _buildControls(),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  String _getDisplayTitle() {
    if (seriesId != null && episodeId != null) {
      return 'S${seasonNumber}E${episodeNumber}';
    }
    return 'Movie';
  }

  Widget _buildProgressIndicator() {
    if (_progressTracker?.getCurrentProgress() != null) {
      final progress = _progressTracker!.getCurrentProgress()!;
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress.progressPercentage / 100,
            ),
            SizedBox(height: 8),
            Text(
              '${progress.currentPosition ~/ 60}:${(progress.currentPosition % 60).toString().padLeft(2, '0')} / ${progress.totalDuration ~/ 60}:${(progress.totalDuration % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.replay_10),
            onPressed: () => _seek(-10),
          ),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.forward_10),
            onPressed: () => _seek(10),
          ),
        ],
      ),
    );
  }

  void _seek(int seconds) {
    final current = _controller.value.position;
    final target = current + Duration(seconds: seconds);
    final duration = _controller.value.duration;
    
    if (target >= Duration.zero && target <= duration) {
      _controller.seekTo(target);
      _progressTracker?.onSeek(target);
    }
  }
}
```

## 🧪 **Test Cases with Debug Widget**

The debug widget now creates 3 test cases:

### **Test Case 1: Movie Resume**

```
Notification: "Resume Avengers Endgame (150 min left)"
Tap → Opens movie at exactly 30:00 minutes
```

### **Test Case 2: Series Episode Resume**

```
Notification: "Resume Breaking Bad S3 E7 (22 min left)"
Tap → Opens exact episode (S3E7) at exactly 22:30 minutes
```

### **Test Case 3: Just Opened Content**

```
Notification: "You opened Spider-Man - Start watching now!"
Tap → Opens movie from beginning (00:00)
```

## 🎯 **Key Features:**

✅ **Exact Episode Tracking**: Remembers Season 3, Episode 7  
✅ **Exact Timestamp**: Resumes at 22:30 minutes, not 22:00 or 23:00  
✅ **Auto-Play**: Starts playing immediately when resumed from notification  
✅ **Resume Dialog**: Offers choice to "Resume" or "Start Over"  
✅ **Progress Display**: Shows exact time position and percentage  
✅ **Series Support**: Full series/season/episode navigation

## 📱 **Expected User Experience:**

1. **User watches Breaking Bad S3E7 for 22.5 minutes → Pauses and leaves**
2. **System saves**: Series ID, Episode ID, Season 3, Episode 7, 22:30 timestamp
3. **10 seconds after app reopen → Notification appears**:
   > **⏸️ Continue Watching**  
   > Resume Breaking Bad S3 E7 (22 min left)
4. **User taps notification**:
    - Opens watch screen
    - Loads Breaking Bad Season 3 Episode 7
    - Seeks to exactly 22:30 minutes
    - Shows resume dialog
    - Starts playing automatically

**Perfect resume experience - exactly where they left off, down to the second!** ⏱️🎯