import 'package:flutter/material.dart';
import '../globals/myFonts.dart';
import '../globals/sizeConfig.dart';

class AuthScreenIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.horizontalBlockSize * 5
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeConfig.screenHeight * 0.08,
            ),
            CircleAvatar(
              backgroundColor: Color.fromRGBO(175, 240, 192, 1),
              radius: 28,
              child: Text(
                "E",
                style: MyFonts.bold.factor(8).setColor(Colors.blue[800]),
              ),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),
            Text(
              "Let's get started",
              style: MyFonts.bold.factor(9),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),
            Text(
              "Plan events with ease",
              style: MyFonts.medium.factor(4),
            ),
          ],
        ),
      ),
    );
  }
}
