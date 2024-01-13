import 'package:flutter/material.dart';
import 'package:niri9/Models/video_details.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Constants/common_functions.dart';
import '../../../Helper/storage.dart';
import '../../../Models/video.dart';
import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/title_box.dart';
import '../../HomeScreen/Widgets/ott_item.dart';
import '../../LanguageSelectedPage/language_selected_page.dart';

class MoreLikeThisSection extends StatefulWidget {
  const MoreLikeThisSection({
    super.key, required this.data,
  });
  final Video data;
  @override
  State<MoreLikeThisSection> createState() => _MoreLikeThisSectionState();
}

class _MoreLikeThisSectionState extends State<MoreLikeThisSection> {

  Future<bool>? _future;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      _future = fetchMoreLikeThis(widget.data.id!, widget.data.video_type_id==1?"single":"multi",widget.data.genres.map((e) => e.name).toList().where((element) => element!="").join(",").toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, _) {
        if(_.hasData&&_.data!=null&&_.data!=false){
          return Consumer<Repository>(builder: (context, data, _) {
            return Column(
              children: [
                TitleBox(
                  isEnd: false,
                  text: "More Like This",
                  onTap: (){},
                ),
                Container(
                  padding:EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  width: double.infinity,
                  height: 20.h,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = data.more_like_this_list[index];
                      return item.videos.isNotEmpty
                          ? OttItem(
                        item: item,
                        onTap: () {
                          if (Storage.instance.isLoggedIn) {
                            Navigation.instance
                                .navigate(Routes.watchScreen, args: item.id);
                          } else {
                            CommonFunctions().showLoginSheet(context);
                            // CommonFunctions().showLoginDialog(context);
                          }
                        },
                      )
                          : Container();
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 2.w,
                      );
                    },
                    itemCount: data.more_like_this_list.length,
                  ),
                ),
              ],
            );
          });
        }
        if(_.hasError||_.data!=null){
          return Container();
        }
        return SizedBox(
            width: double.infinity,
            height: 50.h,
            child: const ShimmerLanguageScreen());
      }
    );
  }
  Future<bool> fetchMoreLikeThis(int id, type, genre) async {
    final response = await ApiProvider.instance
        .getVideos(1, null, null, genre, null, null, type);
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setMoreLikeThisList(response.videos);
      return true;
    } else {
      return false;
    }
  }
}