import 'dart:math';
import 'dart:async';
import '../screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../globals/myColors.dart';
import '../globals/sizeConfig.dart';
import '../screens/login.dart';
import '../providers/tasks.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController scaleController;
  Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3)).then((value) {
      scaleController.forward();
    });

    controller = AnimationController(
      vsync: this,
    );
    _startAnimation();
    scaleController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500
      )
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.stop();
        Timer(
          Duration(
            milliseconds: 300
          ),
          () {
            scaleController.reset();
          },
        );
        User result = FirebaseAuth.instance.currentUser;
        if (result != null) {
          Provider.of<Tasks>(context, listen: false).fetchAndSet(false);
          Navigator.pushAndRemoveUntil(
            context,
            AnimatingRoute(
              route: CalendarScreen(),
            ),
            (route) => false
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            AnimatingRoute(
              route: Login(),
            ),
            (route) => false
          );
        }
      }
    });
    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0
    ).animate(scaleController);
  }

  void _startAnimation() {
    controller.stop();
    controller.reset();
    controller.repeat(
      period: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: darkBlue,
      body: Stack(
        children: [
          Center(
            child: CustomPaint(
              painter: SpritePainter(controller),
              child: Container(),
            ),
          ),
          Center(
            child: CircleAvatar(
              backgroundColor: Color.fromRGBO(175, 240, 192, 1),
              radius: SizeConfig.horizontalBlockSize * 25,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "E",
                      style: GoogleFonts.lobster(
                        fontSize: SizeConfig.horizontalBlockSize * 35,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: scaleAnimation,
                    builder: (c, ch) => Transform.scale(
                      scale: scaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(175, 240, 192, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animationm Logic

class SpritePainter extends CustomPainter {
  final Animation<double> animation;

  SpritePainter(this.animation) : super(repaint: animation);

  void circle(Canvas canvas, Rect rect, double value) {
    double opacity = (1.0 - (value / 4.0)).clamp(.0, 1.0);
    Color color = Colors.blue.withOpacity(opacity);

    double size = rect.width / 2;
    double area = size * size;
    double radius = sqrt(area * value / 4);

    final Paint paint = Paint()..color = color;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + animation.value);
    }
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return true;
  }
}

class AnimatingRoute extends PageRouteBuilder {
  final Widget page;
  final Widget route;

  AnimatingRoute({this.page, this.route})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        FadeTransition(
          opacity: animation,
          child: route,
        ),
  );
}