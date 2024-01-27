import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/ott.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/common_functions.dart';
import '../../Helper/storage.dart';
import '../../Navigation/Navigate.dart';
import '../../Router/routes.dart';
import '../../Widgets/grid_view_shimmering.dart';
import 'Widgets/ottitem.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key, required this.section}) : super(key: key);
  final String section;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  int page_no = 1;

  @override
  void dispose() {
    try {
      Provider.of<Repository>(
              Navigation.instance.navigatorKey.currentContext ?? context,
              listen: false)
          .clearSpecificVideos();
    } catch (e) {
      print(e);
    }
    Future.delayed(const Duration(seconds: 3), () {
      super.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      backgroundColor: Constants.backgroundColor,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: FutureBuilder<List<Video>>(
            future: fetchDetails(page_no, widget.section, null, null, null),
            builder: (context, _) {
             if(_.hasData&&_.data!=null&&(_.data ?? []).isNotEmpty){
               return GridView.builder(
                 itemCount: _.data?.length ?? 0,
                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 3,
                   crossAxisSpacing: 3.w,
                   mainAxisSpacing: 0.7.h,
                   childAspectRatio: 8.5 / 12,
                 ),
                 itemBuilder: (BuildContext context, int index) {
                   var item = _.data![index];
                   return GestureDetector(
                     onTap: () {
                       if (Storage.instance.isLoggedIn) {
                         Navigation.instance
                             .navigate(Routes.watchScreen, args: item.id);
                       } else {
                         CommonFunctions().showLoginDialog(
                             Navigation.instance.navigatorKey.currentContext ??
                                 context);
                         // Navigation.instance.navigate(Routes.watchScreen,args: item.id);
                       }
                     },
                     child: CachedNetworkImage(
                       imageUrl: item.profile_pic ?? "",
                       fit: BoxFit.fill,
                       placeholder: (context, index) {
                         return Image.asset(
                           Assets.logoTransparent,
                         ).animate();
                       },
                     ),
                   );
                 },
               );
             }
             if (_.hasError || (_.hasData&&(_.data ?? []).isEmpty)) {
               return Center(
                 child: Text(
                   "Not Available",
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: Colors.white,
                     fontSize: 14.sp,
                   ),
                 ),
               );
             }
             return const GridViewShimmering();
            }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchDetails(page_no, widget.section, null, null, null);
    });
  }

  Future<List<Video>> fetchDetails(int page_no, String sections,
      String? category, String? genres, String? term) async {
    final response = await ApiProvider.instance.getVideos(
      page_no,
      sections,
      category,
      genres,
      term,
      null,
      null,
    );
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
      return response.videos ?? List<Video>.empty(growable: true);
    } else {
      return List<Video>.empty(growable: true);
    }
  }
}
