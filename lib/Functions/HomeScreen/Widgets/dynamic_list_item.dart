import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:niri9/Constants/common_functions.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/movies.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../Models/ott.dart';
import '../../../Repository/repository.dart';
import '../../../Widgets/title_box.dart';
import 'ott_item.dart';

class DynamicListItem extends StatefulWidget {
  const DynamicListItem(
      {Key? key, required this.text, required this.list, required this.onTap})
      : super(key: key);
  final String text;
  final List<Video> list;
  final Function onTap;

  @override
  State<DynamicListItem> createState() => _DynamicListItemState();
}

class _DynamicListItemState extends State<DynamicListItem> {
  bool isEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add scroll listener for better control
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
        if (isAtEnd != isEnd) {
          setState(() {
            isEnd = isAtEnd;
          });
        }
      }
    } catch (e) {
      debugPrint('Scroll position error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBox(
            isEnd: isEnd,
            text: widget.text,
            onTap: () => widget.onTap(),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 1.h,
            ),
            height: 24.h,
            width: double.infinity,
            child: widget.list.isEmpty
                ? const Center(child: Text('No content available'))
                : ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    cacheExtent: 1000,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index >= widget.list.length) return const SizedBox();

                      var item = widget.list[index];
                      return OttItem(
                        item: item,
                        onTap: () {
                          if (Storage.instance.isLoggedIn) {
                            Navigation.instance
                                .navigate(Routes.watchScreen, args: item.id);
                          } else {
                            CommonFunctions().showLoginSheet(context);
                          }
                        },
                        onLongPressed: () {
                          // Optional: Add long press functionality if needed
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 4.w);
                    },
                    itemCount: widget.list.length,
                  ),
          ),
        ],
      ),
    );
  }
}
