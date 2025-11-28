# 🔧 Testing Watch Progress Notifications

## Quick Debug Steps:

### 1. **Add Debug Widget (Temporary)**

Add this to your home screen for testing:

```dart
// In your home_screen.dart, add this temporarily at the top of the body:
import '../Widgets/notification_debug_widget.dart';

// In the build method, add:
body: Column(
  children: [
    // ADD THIS FOR TESTING ONLY:
    const NotificationDebugWidget(),
    
    // ... rest of your existing body
    Expanded(
      child: SafeArea(
        // ... your existing content
      ),
    ),
  ],
),
```

### 2. **Test Sequence:**

1. **Add Test Progress**: Tap "Add Test Progress" button
2. **Send Test Reminder**: Tap "Send Test Reminder" button
3. **Check Console**: Look for debug messages

### 3. **Expected Debug Output:**

```
🧪 Adding test progress data
💾 Saving watch progress: Test Movie - Avengers Endgame
   Progress: 16.7%
   Should remind: true
   Position: 1800s / 10800s
✅ Progress added to reminder list (total: 1)
💾 Progress saved to storage
✅ Test progress added: 16.7%

🧪 Force sending test reminder  
📤 Sending test reminder for: Test Movie - Avengers Endgame
🔔 _sendContinueWatchingNotification called for: Test Movie - Avengers Endgame
📱 Notification payload created
🎯 Title: 🎬 Continue Watching
📝 Body: Resume Test Movie - Avengers Endgame (150 min left)
📋 Android notification details configured
📲 Attempting to show notification...
✅ Notification.show() called successfully
🆔 Notification ID: 2023456789
✅ Test reminder sent
```

### 4. **Common Issues & Fixes:**

#### **If no debug messages appear:**

- Check if services are initialized in main.dart
- Verify imports are correct

#### **If "No content available for test reminder":**

- The progress percentage might not be in 10%-90% range
- Check the `shouldRemind` logic in WatchProgressModel

#### **If notification.show() called but no notification appears:**

- **Android**: Check notification permissions in Settings
- **Android**: Verify notification channels are created
- **Check Do Not Disturb**: Disable DND mode
- **Check App Notifications**: Enable in device settings

### 5. **Permission Check:**

```dart
// Add this test method to debug permissions
Future<void> checkNotificationPermission() async {
  final permissions = await Permission.notification.status;
  debugPrint('🔐 Notification permission: $permissions');
}
```

### 6. **Manual Permission Request:**

If notifications don't work, manually request permissions:

```dart
await Permission.notification.request();
```

## Quick Fix Commands:

1. **Reset daily reminder limit:**

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('reminder_sent_today');
```

2. **Force show test notification:**

```dart
await WatchProgressService().forceSendTestReminder();
```

3. **Check stored progress:**

```dart
final progress = WatchProgressService().getUnfinishedContent();
debugPrint('📋 Stored progress: ${progress.length} items');
```