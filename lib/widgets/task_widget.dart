import '../globals/myColors.dart';
import '../globals/myFonts.dart';
import '../globals/mySpaces.dart';
import '../globals/sizeConfig.dart';
import '../models/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/edit_task.dart';
import '../providers/tasks.dart';
import '../miscellaneous/functions.dart' as func;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  final BuildContext context;
  final VoidCallback reload;
  TaskWidget(this.context, this.task, this.reload);

  void deleteTask() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Are you sure to delete this task?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance.collection('Users')
                        .doc(FirebaseAuth.instance.currentUser.uid).collection('Tasks')
                        .doc(task.id).delete();
                      Provider.of<Tasks>(context, listen: false).deleteTask(task);
                      reload();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Task deleted successfully"
                          )
                      ));
                    } catch (error) {
                      func.showError(error.toString(), context);
                    }
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: kBlue,
                      fontSize: SizeConfig.textScaleFactor * 20,
                    )
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: kBlue,
                      fontSize: SizeConfig.textScaleFactor * 20,
                    )
                  ),
                )
              ],
            )
          ],
        );
      }
    );
  }

  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: kGrey,
            width: 0.3
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(
            right: 8,
            top: 8,
            left: 8,
            bottom: 8
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      (task.title.length > 20) ?
                      "${task.title.substring(0,20)}..." :
                      "${task.title}",
                      style: MyFonts.bold.size(18),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          child: Icon(
                            Icons.notifications_on,
                            color:kGrey,
                          ),
                          visible: (task.remind=="yes"),
                        ),
                        MySpaces.hGapInBetween,
                        GestureDetector(
                          onTap: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditTask(task),
                              ),
                            ).then((_) => reload());
                          },
                          child: Icon(
                            Icons.edit,
                            color: kBlack,
                            size: 18,
                          ),
                        ),
                        MySpaces.hGapInBetween,
                        GestureDetector(
                          onTap: () {
                            deleteTask();
                            reload();
                          },
                          child: Icon(
                            Icons.delete,
                            color: kBlack,
                            size: 18,
                          ),
                        )
                      ],
                    )
                  )
                ]
              ),
              MySpaces.vGapInBetween,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    child: Text(
                      DateFormat("dd MMM yyyy").format(task.date),
                      style: MyFonts.medium.setColor(kGrey).size(SizeConfig.horizontalBlockSize * 3),
                    ),
                  ),
                  Container(
                    width: 150,
                    child: Text(
                      "${func.hours(task.startTime)}:${func.minutes(task.startTime)}${func.timeMode(task.startTime)} - ${func.hours(task.endTime)}:${func.minutes(task.endTime)}${func.timeMode(task.endTime)}",
                      style: MyFonts.medium.setColor(kGrey).size(SizeConfig.horizontalBlockSize * 3),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
