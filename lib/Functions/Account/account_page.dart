import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(12.h),
        child: Container(
          color: Constants.backgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 4.h,
              ),
              Row(
                children: [
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
              Row(
                children: [
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(
                    "Account settings",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    FontAwesomeIcons.pen,
                    color: Colors.white70,
                    size: 13.sp,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Text(
                    "Manage Profiles",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        child: Consumer<Repository>(builder: (context, data, _) {
          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = data.items[index];
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: Colors.white,
                ),
                title: Text(
                  item.name ?? "",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 0.05.h,
                color: Colors.white,
              );
            },
            itemCount: data.items.length,
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
