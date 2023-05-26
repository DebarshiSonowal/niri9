import 'package:flutter/material.dart';
import 'package:niri9/Functions/Account/account_page.dart';
import 'package:niri9/Functions/FilmFestival/film_festival_page.dart';
import 'package:niri9/Functions/HomeScreen/home_screen.dart';
import 'package:niri9/Functions/LanguageSelectedPage/language_selected_page.dart';
import 'package:niri9/Functions/More/more_page.dart';
import 'package:niri9/Functions/Premium/premium_page.dart';
import 'package:niri9/Functions/RefundPolicy/refund_policy.dart';
import 'package:niri9/Functions/Rent/rent_page.dart';
import 'package:niri9/Functions/Search/search_page.dart';
import 'package:niri9/Router/routes.dart';

import '../Functions/AboutPage/about_page.dart';
import '../Functions/SubscriptionPage/subscription_page.dart';
import '../Functions/WatchScreen/watch_screen.dart';
import '../Widgets/FadeTransitionBuilder.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.homeScreen:
      return FadeTransitionPageRouteBuilder(page: const HomeScreenPage());
    case Routes.searchScreen:
      return FadeTransitionPageRouteBuilder(page: const SearchPage());
    case Routes.premiumScreen:
      return FadeTransitionPageRouteBuilder(page: const PremiumPage());
    case Routes.rentScreen:
      return FadeTransitionPageRouteBuilder(page: const RentPage());
    case Routes.accountScreen:
      return FadeTransitionPageRouteBuilder(page: const AccountPage());
    case Routes.moreScreen:
      return FadeTransitionPageRouteBuilder(
          page: MorePage(index: settings.arguments as int));
    case Routes.selectedLanguageScreen:
      return FadeTransitionPageRouteBuilder(
          page: LanguageSelectedPage(index: settings.arguments as int));
    case Routes.filmFestivalScreen:
      return FadeTransitionPageRouteBuilder(page: const FilmFestivalPage());
    case Routes.watchScreen:
      return FadeTransitionPageRouteBuilder(
          page: WatchScreen(
        index: settings.arguments as int,
      ));
    case Routes.subscriptionScreen:
      return FadeTransitionPageRouteBuilder(page: const SubscriptionPage());
    case Routes.refundScreen:
      return FadeTransitionPageRouteBuilder(page: const RefundPolicyScreen());
    case Routes.aboutScreen:
      return FadeTransitionPageRouteBuilder(page: const AboutPage());

    default:
      return FadeTransitionPageRouteBuilder(
        page: Container(),
      );
  }
}
