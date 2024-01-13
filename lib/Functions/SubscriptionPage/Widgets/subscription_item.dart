import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/subscription.dart';

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem({
    super.key,
    required this.selected,
    required this.item,
    required this.index,
    required this.onTap,
  });

  final int selected, index;
  final Subscription item;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.5.h,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () => onTap(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected == index ? Colors.white : Colors.white30,
                  width: selected == index ? 0.2.h : 0.08.h,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 27.w,
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 0.6.h,
              ),
              child: Consumer<Repository>(
                builder: (context,data,_) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkConditions(data,item.id)?"Current":"UPGRADE TO",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: checkConditions(data,item.id)?Colors.green:Colors.red,
                              fontSize: 9.sp,
                            ),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        item.title ?? "Super",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  selected == index ? checkConditions(data,item.id)?Colors.green:Colors.yellow : Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text.rich(
                        TextSpan(
                          text: '₹',
                          children: <InlineSpan>[
                            TextSpan(
                              text: '${(item.total_price_inr ?? 419).toInt()}',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.sp,
                                      ),
                            )
                          ],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        "/${(item.plan_type ?? '3 Months').capitalize()}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${(item.base_price_inr ?? 599).toInt()}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 8.5.sp,
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                          SizedBox(
                            width: 0.5.w,
                          ),
                          Text(
                            "₹${(item.base_price_usd ?? 100).toInt()} OFF",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: checkConditions(data,item.id)?Colors.green:Colors.red,
                                  fontSize: 11.sp,
                                  // decoration:
                                  // TextDecoration.lineThrough,
                                ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
          selected == index
              ? Consumer<Repository>(
                builder: (context,data,_) {
                  return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: checkConditions(data,item.id)?Colors.green:Colors.red,
                      ),
                    );
                }
              )
              : Container(),
        ],
      ),
    );
  }

  checkConditions(Repository data, int? id) {
    if(data.user?.last_subscription??false){
      return false;
    }
    if(data.user?.last_sub?.lastSubscription?.id==id){
      return true;
    }
    return false;
  }
}
