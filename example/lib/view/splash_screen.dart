import 'package:flutter/material.dart';

import '../core/media_query_values.dart';
import 'camera_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController, appNameController;

  late Animation<double> opacityAnim, appNameOpacityAnim;
  late Animation<double> scaleAnim;
  late Animation<double> positionAnim;

  @override
  void initState() {
    super.initState();
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ),
    )..forward();

    appNameController = AnimationController(
      value: 0,
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ),
    );

    scaleAnim = Tween<double>(begin: 2, end: 1).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.linear,
        ),
      ),
    );

    opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(
          0,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    positionAnim = Tween<double>(begin: 0, end: -33).animate(
      CurvedAnimation(
        parent: appNameController,
        curve: const Interval(
          0,
          1,
          curve: Curves.linear,
        ),
      ),
    );
    appNameOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: appNameController,
        curve: const Interval(
          0,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    logoController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          appNameController.forward();
        }
      },
    );

    appNameController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(
            const Duration(seconds: 1),
            () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            AnimatedBuilder(
              animation: logoController,
              builder: (BuildContext context, Widget? child) {
                return ScaleTransition(
                  scale: scaleAnim,
                  child: Image.asset(
                    'assets/images/icon.png',
                    opacity: opacityAnim,
                    width: context.responsiveWidth(200),
                    height: context.responsiveHeight(200),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: appNameController,
              builder: (context, child) {
                return AnimatedPositioned(
                  bottom: positionAnim.value - context.responsiveHeight(50),
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: appNameOpacityAnim.value,
                    child: Text(
                      'Snapchat Filters',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Bolt',
                          ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
