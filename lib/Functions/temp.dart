import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:sizer/sizer.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.h),
        child: AnimatedBackground(
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              spawnMaxRadius: 20.w,
              spawnMaxSpeed: 50.00,
              particleCount: 20,
              spawnMinSpeed: 10.00,
              minOpacity: 0.3,
              spawnOpacity: 0.4,
              image: Image.asset(Assets.logoTransparent),
            ),
          ),
          vsync: this,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                "Upgrade to get the most out of your NIRI9 subscription",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: 100.h,
        width: 100.w,
        // child: ,
        // ),
      ),
    );
  }
}
