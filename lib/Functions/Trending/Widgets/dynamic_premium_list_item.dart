import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/common_functions.dart';
import '../../../Models/ott.dart';
import '../../../Models/video.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import '../../HomeScreen/Widgets/ott_item.dart';
import 'premium_ott_item.dart';
import 'numbered_ott_item.dart';

class DynamicPremiumListItem extends StatefulWidget {
  const DynamicPremiumListItem(
      {Key? key, required this.text, required this.list, required this.onTap})
      : super(key: key);
  final String text;
  final List<Video> list;
  final Function onTap;

  @override
  State<DynamicPremiumListItem> createState() => _DynamicPremiumListItemState();
}

class _DynamicPremiumListItemState extends State<DynamicPremiumListItem> {
  bool isEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChange);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChange() {
    if (!_scrollController.hasClients) return;

    try {
      final position = _scrollController.position;
      if (position.pixels.isFinite && position.maxScrollExtent.isFinite) {
        final isAtEnd = position.pixels >= position.maxScrollExtent - 50;
        if (isAtEnd != isEnd && mounted) {
          setState(() {
            isEnd = isAtEnd;
          });
        }
      }
    } catch (e) {
      debugPrint('Scroll position error in premium list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Netflix-style section title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onTap(),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade400,
                          size: 4.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Netflix-style numbered items list
          Container(
            height: 24.h,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final ScrollDirection direction = notification.direction;
                final ScrollMetrics metrics = notification.metrics;

                if (direction == ScrollDirection.forward &&
                    metrics.pixels > 0) {
                  // Slight swipe to the right
                  setState(() {
                    isEnd = false;
                  });
                } else if (direction == ScrollDirection.reverse &&
                    metrics.pixels < metrics.maxScrollExtent) {
                  // Slight swipe to the left

                  setState(() {
                    isEnd = true;
                  });
                }

                return true;
              },
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                itemBuilder: (context, index) {
                  var item = widget.list[index];
                  return NumberedOttItem(
                    index: index,
                    item: item,
                    onTap: () {
                      if (Storage.instance.isLoggedIn) {
                        Navigation.instance
                            .navigate(Routes.watchScreen, args: item.id);
                      } else {
                        CommonFunctions().showLoginDialog(context);
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 4.w);
                },
                itemCount: widget.list.length > 10
                    ? 10
                    : widget.list.length, // Limit to top 10
              ),
            ),
          ),
        ],
      ),
    );
  }
}
