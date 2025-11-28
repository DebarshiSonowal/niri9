import 'package:flutter/material.dart';
import '../Functions/Notifications/watch_progress_service.dart';

class NotificationDebugWidget extends StatelessWidget {
  const NotificationDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DEBUG: Notification Testing',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await WatchProgressService().addTestProgress();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test progress added!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Add Test Progress'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await WatchProgressService().forceSendTestReminder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test reminder sent!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Send Test Reminder'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await WatchProgressService().recordAppOpen();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('App open recorded (10sec timer started)')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Simulate App Open'),
          ),
        ],
      ),
    );
  }
}