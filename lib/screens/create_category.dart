import '../globals/mySpaces.dart';
import '../models/group.dart';
import '../providers/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import '../globals/myFonts.dart';
import '../globals/sizeConfig.dart';
import '../miscellaneous/functions.dart' as func;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditCategoryScreen extends StatefulWidget {
  static const routeName = 'edit-category-screen';
  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  var isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _title;
  Color _color;

  void saveForm() async {
    _formKey.currentState.save();
    if(_title == null || _color == null){
      func.showError("One or more field is empty. Please fill all the fields.", context);
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final _id = FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser.uid).collection('Categories').doc();
      var category = Group(
        id: _id.id,
        title: _title,
        color: _color,
      );
      _id.set(category.toMap());
      Provider.of<Tasks>(context, listen: false).addCategory(category);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Category created successfully"
        )
      ));
    } catch (error) {
      func.showError(error.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: isLoading ?
        Center(
          child: CircularProgressIndicator(),
        ) :
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 15
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MySpaces.vGapInBetween,
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Add New Category',
                      style: MyFonts.bold.size(SizeConfig.horizontalBlockSize * 8),
                    ),
                  ),
                  MySpaces.vLargeGapInBetween,
                  TextFormField(
                    cursorHeight: 28,
                    cursorColor: Colors.grey[400],
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.grey[600]
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey
                      ),
                      focusColor: Colors.grey[800],
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade900,
                        ),
                      ),
                      hintText: 'Category Name',
                    ),
                    onSaved: (value) {
                      _title = value;
                    },
                  ),
                  MySpaces.vSmallGapInBetween,
                  MaterialColorPicker(
                    onColorChange: (Color color) {
                      _color = color;
                    },
                  ),
                  MySpaces.vMediumGapInBetween,
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: saveForm,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
