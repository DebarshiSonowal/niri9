import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Navigation/Navigate.dart';

class SearchAppbar extends StatelessWidget {
  const SearchAppbar({
    super.key,
    required this.search, required this.suggest, required this.searchEditingController,
  });

  final Function(String) search,suggest;
  final TextEditingController searchEditingController;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                onTap: () {
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
            height: 1.h,
          ),
          Container(
            height: 37.sp,
            padding: EdgeInsets.symmetric(horizontal: 4.5.w),
            child: TextField(
              controller: searchEditingController,
              onChanged: (val) {
                if (val != "") {
                  suggest(val);
                }
              },
              onSubmitted: (val) {
                if (val != "") {
                  search(val);
                }
              },
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
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
    );
  }
}
