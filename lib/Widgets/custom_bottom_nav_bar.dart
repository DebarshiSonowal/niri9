import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Constants/assets.dart';
import '../Constants/constants.dart';
import '../Navigation/Navigate.dart';
import '../Repository/repository.dart';
import '../Router/routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Constants.bottomNavigationBarBackgroundColor,
      type: BottomNavigationBarType.shifting,
      // unselectedItemColor: Color(0xff9a9a9a),
      onTap: (int val) {
        Provider.of<Repository>(context, listen: false).updateIndex(val);
        switch (val) {
          case 1:
            Navigation.instance.navigate(Routes.searchScreen, args: "");
            break;
          case 2:
            Navigation.instance.navigate(Routes.premiumScreen);
            break;
          case 3:
            Navigation.instance.navigate(Routes.rentScreen);
            break;
          case 4:
            Navigation.instance.navigate(Routes.accountScreen);
            break;
          default:
            Navigation.instance.navigate(Routes.homeScreen);
            break;
        }
      },
      selectedFontSize: 13.sp,
      unselectedFontSize: 11.sp,
      showUnselectedLabels: true,
      unselectedIconTheme: const IconThemeData(color: Color(0xff9a9a9a)),
      currentIndex:
          Provider.of<Repository>(context, listen: false).currentIndex,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Constants.bottomNavigationBarBackgroundColor,
          icon: Image.asset(
            Assets.homeImage,
            scale: 24,
            color:
                Provider.of<Repository>(context, listen: false).currentIndex ==
                        0
                    ? Colors.red
                    : Colors.white,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          backgroundColor: Constants.bottomNavigationBarBackgroundColor,
          icon: Image.asset(
            Assets.searchImage,
            scale: 24,
            color:
                Provider.of<Repository>(context, listen: false).currentIndex ==
                        1
                    ? Colors.red
                    : Colors.white,
          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          backgroundColor: Constants.bottomNavigationBarBackgroundColor,
          icon: Image.asset(
            Assets.premiumImage,
            scale: 24,
            color:
                Provider.of<Repository>(context, listen: false).currentIndex ==
                        2
                    ? Colors.red
                    : Colors.white,
          ),
          label: "Trending",
        ),
        BottomNavigationBarItem(
          backgroundColor: Constants.bottomNavigationBarBackgroundColor,
          icon: Image.asset(
            Assets.rentImage,
            // color: Colors.white,
            scale: 24,
            color:
                Provider.of<Repository>(context, listen: false).currentIndex ==
                        3
                    ? Colors.red
                    : Colors.white,
          ),
          label: "Rent",
        ),
        BottomNavigationBarItem(
          backgroundColor: Constants.bottomNavigationBarBackgroundColor,
          icon: Image.asset(
            Assets.accountImage,
            color:
                Provider.of<Repository>(context, listen: false).currentIndex ==
                        4
                    ? Colors.red
                    : Colors.white,
            scale: 24,
          ),
          label: "Account",
        ),
      ],
    );
  }
}
