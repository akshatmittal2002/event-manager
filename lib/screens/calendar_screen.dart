import '../globals/myFonts.dart';
import '../screens/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import './drawer.dart';
import '../globals/sizeConfig.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar-page';
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
                    isDrawerOpen ? 40 : 0
                )
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      top: topPadding
                    ),
                    child: IntrinsicHeight(
                      child: Stack(
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
                                xOffset =
                                    SizeConfig.horizontalBlockSize * 70;
                                yOffset =
                                    SizeConfig.verticalBlockSize * 7;
                                scaleFactor = 0.85;
                                isDrawerOpen = true;
                                topPadding = 15;
                              });
                            },
                          ),
                          Center(
                            child: Text(
                              DateFormat("dd MMMM yyyy").format(DateTime.now()),
                              style: MyFonts.bold.size(SizeConfig.textScaleFactor * 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Calendar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
