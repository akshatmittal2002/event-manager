import '../globals/myFonts.dart';
import '../globals/mySpaces.dart';
import '../models/group.dart';
import '../providers/tasks.dart';
import '../screens/create_task.dart';
import '../screens/create_category.dart';
import '../widgets/category_button.dart';
import '../widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals/myColors.dart';
import '../globals/sizeConfig.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  double topPadding = 0;
  bool isDrawerOpen = false;
  Group currentCat;

  final Group allTasksCat = Group(
    title: "All Tasks",
    icon: Icons.today_outlined,
    color: kWhite,
  );

  @override
  void initState() {
    super.initState();
    currentCat = allTasksCat;
  }

  @override
  Widget build(BuildContext context) {
    final taskData = Provider.of<Tasks>(context);
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 13),
            width: SizeConfig.horizontalBlockSize * 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TASKS LIST",
                            style: MyFonts.medium.setColor(kBlue).size(SizeConfig.horizontalBlockSize * 4),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: kGrey,
                                  size: SizeConfig.horizontalBlockSize * 4,
                                ),
                                MySpaces.hSmallestGapInBetween,
                                Text(
                                  DateFormat("dd MMMM yyyy").format(taskData.selectedDate),
                                  style: MyFonts.medium.setColor(kBlue).size(SizeConfig.horizontalBlockSize * 4),
                                )
                              ],
                            )
                          )
                        ]
                      ),
                      MySpaces.vSmallestGapInBetween,
                      Text(
                        currentCat.title ?? "All Tasks",
                        style: MyFonts.bold.size(SizeConfig.horizontalBlockSize * 10),
                      ),
                      MySpaces.vGapInBetween,
                      if (currentCat == allTasksCat)
                        ...taskData.todaysTask.map((task) {
                          return TaskWidget(context,task,(){setState((){});});
                        }).toList(),
                      if (currentCat != allTasksCat)
                        ...taskData.availableTasks(currentCat).map((task) {
                          return TaskWidget(context,task,(){setState((){});});
                        }).toList(),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreateNewTask.routeName).then((_){
                        setState(() {});
                      });
                    },
                    child: Text(
                      "📝   ADD NEW TASK",
                      style: MyFonts.medium.size(SizeConfig.horizontalBlockSize * 4),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 13
                      ),
                      primary: kWhite,
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: SizeConfig.horizontalBlockSize * 18,
            color: matteBlack,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MySpaces.vGapInBetween,
                CategoryButton(
                  context,
                  allTasksCat,
                  () {
                    setState(() {
                      currentCat = allTasksCat;
                    });
                  },
                  false,
                  () {}
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      return CategoryButton(
                        context,
                        taskData.categories[index],
                        () {
                          setState(() {
                            currentCat = taskData.categories[index];
                          });
                        },
                        true,
                        () {
                          setState(() {
                            currentCat = allTasksCat;
                          });
                        },
                      );
                    },
                    itemCount: taskData.categories.length,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(EditCategoryScreen.routeName).then((_){
                      setState(() {});
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: kWhite,
                    size: SizeConfig.verticalBlockSize * 4,
                  ),
                ),
                MySpaces.vSmallGapInBetween,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
