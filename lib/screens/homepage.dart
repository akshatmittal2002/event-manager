import '../globals/myColors.dart';
import '../screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import './drawer.dart';
import '../screens/tasks_screen.dart';
import '../globals/sizeConfig.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  double topPadding = 0;
  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            DrawerScreen(),
            AnimatedContainer(
              transform: Matrix4.translationValues(
                  xOffset, yOffset, 0
              )..scale(scaleFactor),
              duration: Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  isDrawerOpen ? 40 : 0.0
                )
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5, top: topPadding),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isDrawerOpen ?
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios
                            ),
                            onPressed: () {
                              setState(() {
                                xOffset = 0;
                                yOffset = 0;
                                scaleFactor = 1;
                                isDrawerOpen = false;
                                topPadding = 0;
                              });
                            },
                          ) :
                          IconButton(
                            icon: Icon(
                              Icons.menu
                            ),
                            onPressed: () {
                              setState(() {
                                xOffset = SizeConfig.horizontalBlockSize * 70;
                                yOffset = SizeConfig.verticalBlockSize * 7;
                                scaleFactor = 0.85;
                                isDrawerOpen = true;
                                topPadding = 15;
                              });
                            },
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 10
                            ),
                            color: matteBlack,
                            width: SizeConfig.horizontalBlockSize * 18,
                            height: double.infinity,
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(CalendarScreen.routeName);
                              },
                              icon: Icon(
                                Icons.calendar_today_rounded,
                                color: kGrey,
                                size: SizeConfig.verticalBlockSize * 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TasksScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
