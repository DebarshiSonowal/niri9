import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';
import '../../../Models/video.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import '../../HomeScreen/Widgets/ott_item.dart';
import 'premium_ott_item.dart';

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
    _scrollController.addListener(() {
      if (_scrollController.offset <= _scrollController.position.minScrollExtent&&isEnd!=false) {
        setState(() {
          debugPrint("reach the top");
          isEnd = false;
        });
      }
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent&&isEnd==false) {
        setState(() {
          debugPrint("reach the bottom");
          isEnd = true;
        });
      }
    });
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
            // color: Colors.green,
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 1.h,
            ),
            height: 24.h,
            width: double.infinity,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var item = widget.list[index];
                return OttItem(
                  // index: index,
                  item: item,
                  onTap: () {
                    Navigation.instance
                        .navigate(Routes.watchScreen, args: item.id);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 4.w,
                );
              },
              itemCount: widget.list.length,
            ),
          ),
        ],
      ),
    );
  }
}
