import 'package:flutter/material.dart';
import 'package:niri9/Functions/Account/account_page.dart';
import 'package:niri9/Functions/FilmFestival/film_festival_page.dart';
import 'package:niri9/Functions/Help/help_faq_page.dart';
import 'package:niri9/Functions/HomeScreen/home_screen.dart';
import 'package:niri9/Functions/LanguageSelectedPage/language_selected_page.dart';
import 'package:niri9/Functions/Login/login_page.dart';
import 'package:niri9/Functions/More/more_page.dart';
import 'package:niri9/Functions/NotificationInbox/notification_inbox_screen.dart';
import 'package:niri9/Functions/Orders/orders_page.dart';
import 'package:niri9/Functions/Otp/otp_screen.dart';

// import 'package:niri9/Functions/Premium/trending_page.dart';
import 'package:niri9/Functions/Privacy/privacy_policy.dart';
import 'package:niri9/Functions/ProfilePage/profile_page.dart';
import 'package:niri9/Functions/ProfileUpdate/profile_update_page.dart';
import 'package:niri9/Functions/RefundPolicy/refund_policy.dart';
import 'package:niri9/Functions/Rent/rent_page.dart';
import 'package:niri9/Functions/Search/search_page.dart';
import 'package:niri9/Functions/TermsConditions/terms_conditions.dart';
import 'package:niri9/Functions/WatchList/watch_list_screen.dart';
import 'package:niri9/Router/routes.dart';

import '../Functions/AboutPage/about_page.dart';
import '../Functions/ActivateTV/activate_tc.dart';
import '../Functions/CategorySpecific/category_specific_screen.dart';
import '../Functions/Cupon/apply_cupons.dart';
import '../Functions/RecentlyViewed/recently_viewed_screen.dart';
import '../Functions/SplashScreen/splash_screen.dart';
import '../Functions/SubscriptionPage/subscription_page.dart';
import '../Functions/Trending/trending_page.dart';
import '../Functions/WatchScreen/watch_screen.dart';
import '../Widgets/FadeTransitionBuilder.dart';
import '../Widgets/loading_dialog.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splashScreen:
      return FadeTransitionPageRouteBuilder(page: const SplashScreen());
    case Routes.loginScreen:
      return FadeTransitionPageRouteBuilder(page: const LoginPage());
    case Routes.otpScreen:
      return FadeTransitionPageRouteBuilder(
          page: OtpPage(mobile: settings.arguments as String));
    case Routes.profile:
      return FadeTransitionPageRouteBuilder(page: const ProfilePage());
    //main
    case Routes.homeScreen:
      return FadeTransitionPageRouteBuilder(page: const HomeScreenPage());
    case Routes.searchScreen:
      return FadeTransitionPageRouteBuilder(
          page: SearchPage(
        filters: settings.arguments as String,
      ));
    case Routes.premiumScreen:
      return FadeTransitionPageRouteBuilder(page: const TrendingPage());
    case Routes.rentScreen:
      return FadeTransitionPageRouteBuilder(page: const RentPage());
    case Routes.accountScreen:
      return FadeTransitionPageRouteBuilder(page: const AccountPage());
    case Routes.profileUpdateScreen:
      return FadeTransitionPageRouteBuilder(page: const ProfileUpdatePage());
    case Routes.moreScreen:
      return FadeTransitionPageRouteBuilder(
          page: MorePage(section: settings.arguments as String));
    case Routes.selectedLanguageScreen:
      return FadeTransitionPageRouteBuilder(
          page: LanguageSelectedPage(language: settings.arguments as String));
    case Routes.selectedCategoryScreen:
      return FadeTransitionPageRouteBuilder(
          page:
              CategorySpecificScreen(searchTerm: settings.arguments as String));
    case Routes.filmFestivalScreen:
      return FadeTransitionPageRouteBuilder(page: const FilmFestivalPage());
    case Routes.watchScreen:
      return FadeTransitionPageRouteBuilder(
          page: WatchScreen(
        id: settings.arguments as int,
      ));
    case Routes.subscriptionScreen:
      return FadeTransitionPageRouteBuilder(page: const SubscriptionPage());

    //Extra
    case Routes.orderHistory:
      return FadeTransitionPageRouteBuilder(page: const OrderPageScreen());
    case Routes.cuponApply:
      return FadeTransitionPageRouteBuilder(page: const ApplyCuponsPage());
    case Routes.refundScreen:
      return FadeTransitionPageRouteBuilder(page: const RefundPolicyScreen());
    case Routes.privacyPolicyScreen:
      return FadeTransitionPageRouteBuilder(page: const PrivacyPolicyScreen());
    case Routes.helpFaqScreen:
      return FadeTransitionPageRouteBuilder(page: const HelpFaqPage());
    case Routes.aboutScreen:
      return FadeTransitionPageRouteBuilder(page: const AboutPage());
    case Routes.activateTV:
      return FadeTransitionPageRouteBuilder(page: const ActivateTvScreen());
    case Routes.notificationInbox:
      return FadeTransitionPageRouteBuilder(page: const NotificationInboxScreen());

    case Routes.watchlistScreen:
      return FadeTransitionPageRouteBuilder(page: const WatchListScreen());
    case Routes.recentlyViewedScreen:
      return FadeTransitionPageRouteBuilder(page: const RecentlyViewedScreen());
    case Routes.termsConditionsScreen:
      return FadeTransitionPageRouteBuilder(
          page: const TermsConditionsScreen());
    case Routes.loadingScreen:
      return FadeTransitionPageRouteBuilder(page: LoadingDialog());

    default:
      return FadeTransitionPageRouteBuilder(
        page: Container(),
      );
  }
}
