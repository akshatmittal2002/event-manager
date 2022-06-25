import '../globals/myFonts.dart';
import '../models/group.dart';
import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:provider/provider.dart';
import '../providers/tasks.dart';
import '../globals/myColors.dart';
import '../globals/sizeConfig.dart';
import '../miscellaneous/functions.dart' as func;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class CategoryButton extends StatelessWidget {
  final Group grp;
  final Function function;
  final BuildContext context;
  final bool isVisible;
  final VoidCallback reload;
  const CategoryButton(this.context, this.grp, this.function, this.isVisible, this.reload);

  deleteCategory() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Are you sure to delete this category?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "All tasks in this category will also be deleted.",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      final _task = FirebaseFirestore.instance.collection('Users')
                        .doc(FirebaseAuth.instance.currentUser.uid).collection('Tasks');
                      await _task.get().then((value){
                        value.docs.forEach((element){
                          if(Task.fromMap(element.data()).category.id == grp.id){
                            _task.doc(element.id).delete();
                          }
                        });
                      });
                      await FirebaseFirestore.instance.collection('Users')
                        .doc(FirebaseAuth.instance.currentUser.uid).collection('Categories')
                        .doc(grp.id).delete();
                      Provider.of<Tasks>(context, listen: false).deleteCategory(grp);
                      reload();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Category deleted successfully"
                          )
                      ));
                    } catch (error) {
                      Navigator.of(context).pop();
                      func.showError(error.toString(),context);
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.horizontalBlockSize * 2.5,
            ),
            margin: EdgeInsets.symmetric(
              vertical: 5
            ),
            child: AnimatedButton(
              width: SizeConfig.horizontalBlockSize * 13,
              child: (grp.icon != null) ?
              Icon(
                grp.icon,
                color: grp.color,
              ) :
              Text(
                grp.title.toUpperCase().substring(0, 1),
                style: MyFonts.bold.setColor(grp.color).size(25),
              ),
              color: matteBlackLite,
              onPressed: function,
              enabled: true,
              shadowDegree: ShadowDegree.light,
            ),
          ),
          Visibility(
            child: Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: kGrey,
                  size: 25,
                ),
                onTap: (){
                  deleteCategory();
                },
              ),
            ),
            visible: isVisible && grp.title != "Personal",
          )
        ],
      )
    );
  }
}
