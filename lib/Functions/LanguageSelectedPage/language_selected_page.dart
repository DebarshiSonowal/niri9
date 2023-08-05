import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';

class LanguageSelectedPage extends StatelessWidget {
  const LanguageSelectedPage({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: Container(
          color: Constants.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    // SizedBox(
                    //   width: 5.w,
                    // ),
                    Text(
                      "Assamese",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 15.sp,
                            // fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        child: Consumer<Repository>(builder: (context, data, _) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var item = data.sections[index];
              return DynamicListItem(
                text: item.title ?? "",
                list: item.videos ?? [],
                onTap: () {
                  Navigation.instance.navigate(Routes.moreScreen,args: 0);
                },
              );
            },
            itemCount:data.sections.length,
          );
        }),
      ),
    );
  }
}
