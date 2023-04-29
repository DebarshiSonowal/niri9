import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Repository/repository.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(12.4.h),
        child: Container(
          color: Constants.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 6.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 3.w,
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigation.instance.goBack();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_sharp,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    "Search",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          // fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Container(
                height: 37.sp,
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                child: TextField(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.black45,
                        fontSize: 11.sp,
                      ),
                      hintText: "Search for movies, shows, etc.",
                      fillColor: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: 3.h,
                left: 2.5.w,
              ),
              child: Text(
                "Today's Top Searches",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 11.5.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<Repository>(builder: (context, data, _) {
              return Expanded(
                child: GridView.builder(
                  itemCount: data.selectedCategory.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 0.5.h,
                    childAspectRatio: 9 / 12,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    var item = data.selectedCategory[index];
                    return OttItem(item: item, onTap: () {});
                  },
                ),
              );
            }),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
