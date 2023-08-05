import 'package:flutter/material.dart';
import 'package:niri9/Models/movies.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import 'ott_item.dart';

class DynamicListItem extends StatelessWidget {
  const DynamicListItem({Key? key, required this.text, required this.list, required this.onTap}) : super(key: key);
final String text;
final List<Video> list;
final Function onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25.h,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBox(
            text: text,
            onTap: ()=>onTap(),
          ),
          Container(
            // color: Colors.green,
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 1.h,
            ),
            height: 19.h,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var item = list[index];
                return OttItem(
                  item: item,
                  onTap: () {
                    Navigation.instance.navigate(Routes.watchScreen,args: item.id);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 2.w,
                );
              },
              itemCount:list.length,
            ),
          ),
        ],
      ),
    );
  }
}
