import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/ott.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import 'premium_ott_item.dart';

class DynamicPremiumListItem extends StatelessWidget {
  const DynamicPremiumListItem({Key? key, required this.text, required this.list, required this.onTap}) : super(key: key);
  final String text;
  final List<OTT> list;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 23.h,
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
            height: 17.h,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var item = list[index];
                return PremiumOttItem(
                  index: index,
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