import 'package:flutter/material.dart';

import '../../Widgets/custom_bottom_nav_bar.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
