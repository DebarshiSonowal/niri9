import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Navigation/Navigate.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import 'dynamic_list_item.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Consumer<Repository>(builder: (context, data, _) {
        return data.recently_viewed_list.isNotEmpty?
        DynamicListItem(
          text: 'Recently Viewed',
          list: data.recently_viewed_list,
          onTap: () {
            Navigation.instance
                .navigate(Routes.recentlyViewedScreen,);
          },
        )
            :Container();
      }),
    );
  }
}