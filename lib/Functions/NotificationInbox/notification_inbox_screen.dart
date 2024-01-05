import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/category_specific_appbar.dart';
import '../CategorySpecific/category_specific_screen.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: const CategorySpecificAppbar(searchTerm: "Notification Inbox"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 2.h,
        ),

      ),
    );
  }
}
