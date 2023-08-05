import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Models/account_item.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
                onTap: () {
                  onTap(index, item);
                  // debugPrint("Item");
                },
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

  void onTap(int index, AccountItem item) {
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        // _launchUrl(Uri.parse("https://niri9.com/terms-condition.php"));
        Navigation.instance.navigate(Routes.termsConditionsScreen);
        break;
      case 5:
        // _launchUrl(Uri.parse("https://niri9.com/privacy_policy.php"));
        Navigation.instance.navigate(Routes.privacyPolicyScreen);
        break;
      case 6:
        Navigation.instance.navigate(Routes.refundScreen);
        break;
      case 7:
        Navigation.instance.navigate(Routes.helpFaqScreen);
        break;
      case 8:
        Navigation.instance.navigate(Routes.aboutScreen);
        break;
      case 9:
        break;
      default:
        Navigation.instance.navigate(Routes.loginScreen);
        break;
    }
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }
}
