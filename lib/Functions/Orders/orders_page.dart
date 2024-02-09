import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Models/order_history.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';

class OrderPageScreen extends StatefulWidget {
  const OrderPageScreen({super.key});

  @override
  State<OrderPageScreen> createState() => _OrderPageScreenState();
}

class _OrderPageScreenState extends State<OrderPageScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () => fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(14.h),
        child: Column(
          children: [
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigation.instance.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 4.w,
                ),
                Image.asset(
                  Assets.logoTransparent,
                  height: 7.5.h,
                  width: 14.w,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            SizedBox(
              height: 0.1.h,
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: "Orders",
                ),
                Tab(
                  text: "Rentals",
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        width: double.infinity,
        height: double.infinity,
        child: TabBarView(
          controller: _tabController,
          children: const [
            OrderItemsList(),
            RentItemsList(),
          ],
        ),
      ),
    );
  }

  void fetchOrders() async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getOrderHistory();
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .setOrders(response.result ?? []);
    } else {
      Navigation.instance.goBack();
    }
  }
}

class OrderItemsList extends StatelessWidget {
  const OrderItemsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Consumer<Repository>(builder: (context, data, _) {
        return ListView.separated(
          itemBuilder: (context, index) {
            var item = data.orders
                .where((element) => element.order_for == "subscription")
                .toList()[index];
            return OrderItemWidget(item: item);
          },
          itemCount: data.orders
              .where((element) => element.order_for == "subscription")
              .toList().length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 2.h,
            );
          },
        );
      }),
    );
  }
}

class RentItemsList extends StatelessWidget {
  const RentItemsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Consumer<Repository>(builder: (context, data, _) {
        return ListView.separated(
          itemBuilder: (context, index) {
            var item = data.orders
                .where((element) => element.order_for != "subscription")
                .toList()[index];
            return OrderItemWidget(item: item);
          },
          itemCount: data.orders
              .where((element) => element.order_for != "subscription")
              .toList().length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 2.h,
            );
          },
        );
      }),
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget({
    super.key,
    required this.item,
  });

  final OrderHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.5.h,
      ),
      decoration: BoxDecoration(
        color: Constants.subscriptionCardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 20.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Order Id: ",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 8.sp,
                    ),
              ),
              SizedBox(
                child: Text(
                  "${item.id}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                "Date: ",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 8.sp,
                    ),
              ),
              SizedBox(
                child: Text(
                  "${item.orderDate?.split(" ").first}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.productName ?? "N/A",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 8.w,
                child: Text(
                  "Total: ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 8.sp,
                      ),
                ),
              ),
              SizedBox(
                width: 20.w,
                child: Row(
                  children: [
                    Text(
                      "₹${item.total}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Text(
                  "Tax: ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 8.sp,
                      ),
                ),
              ),
              SizedBox(
                width: 15.w,
                child: Text(
                  "₹${item.taxAmt}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                    fontSize: 12.sp,
                      ),
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Text(
                  "Grand Total: ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 8.sp,
                      ),
                ),
              ),
              SizedBox(
                width: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "₹${item.grandTotal}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                        fontSize: 12.sp,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
