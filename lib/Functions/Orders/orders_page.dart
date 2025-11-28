import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(14.h),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Color(0xFF1A1A1A),
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigation.instance.goBack();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Image.asset(
                      Assets.logoTransparent,
                      height: 6.h,
                      width: 12.w,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    Text(
                      "Order History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Color(0xFFB71C1C)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.subscriptions, size: 18),
                            SizedBox(width: 1.w),
                            Text("Subscriptions"),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie, size: 18),
                            SizedBox(width: 1.w),
                            Text("Rentals"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Colors.black,
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                .where((element) => element.orderFor == "subscription")
                .toList()[index];
            return OrderItemWidget(item: item);
          },
          itemCount: data.orders
              .where((element) => element.orderFor == "subscription")
              .toList()
              .length,
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
                .where((element) => element.orderFor != "subscription")
                .toList()[index];
            return OrderItemWidget(item: item);
          },
          itemCount: data.orders
              .where((element) => element.orderFor != "subscription")
              .toList()
              .length,
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

  final Result item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderInfo(
                        icon: Icons.receipt_long_rounded,
                        title: "Order ID",
                        value: "#${item.id.toString().padLeft(6, '0')}",
                      ),
                      _buildHeaderInfo(
                        icon: Icons.schedule_rounded,
                        title: "Date",
                        value: _formatOrderDate(item.orderDate),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        item.orderFor == "subscription"
                            ? Icons.subscriptions_rounded
                            : Icons.movie_rounded,
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          item.productData?.title ?? "N/A",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      _buildStatusChip(item.isPaid == 1),
                    ],
                  ),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Date information cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateCard(
                          context: context,
                          title: "Activated",
                          date: item.productData?.activeDate,
                          icon: Icons.rocket_launch_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildDateCard(
                          context: context,
                          title: "Expires",
                          date: item.productData?.expiryDate,
                          icon: Icons.schedule_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Pricing section
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriceItem(
                                "Subtotal",
                                item.total,
                                Colors.white70,
                              ),
                            ),
                            Expanded(
                              child: _buildPriceItem(
                                "Tax",
                                item.taxAmt,
                                Colors.white70,
                              ),
                            ),
                            Expanded(
                              child: _buildPriceItem(
                                "Total",
                                item.grandTotal,
                                Colors.red,
                                isBold: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 4.w),
            SizedBox(width: 1.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isPaid) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.white.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.white : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        isPaid ? "PAID" : "PENDING",
        style: TextStyle(
          color: isPaid ? Colors.white : Colors.red,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriceItem(
    String label,
    dynamic amount,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          "₹${double.tryParse(amount?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
          style: TextStyle(
            color: color,
            fontSize: isBold ? 14.sp : 12.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatOrderDate(String? orderDate) {
    if (orderDate == null || orderDate.isEmpty) return "N/A";
    try {
      final dateTime = DateTime.parse(orderDate);
      return DateFormat("MMM dd").format(dateTime);
    } catch (e) {
      return orderDate.split(" ").first;
    }
  }

  Widget _buildDateCard({
    required BuildContext context,
    required String title,
    required String? date,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color == Colors.white
            ? Colors.white.withOpacity(0.1)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color == Colors.white
                ? Colors.white.withOpacity(0.3)
                : Colors.red.withOpacity(0.5),
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            date != null && date.isNotEmpty
                ? _formatOrderDate(date)
                : "Not Available",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
