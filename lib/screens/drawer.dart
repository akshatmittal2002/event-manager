import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../globals/myColors.dart';
import '../globals/myFonts.dart';
import '../globals/mySpaces.dart';
import '../globals/sizeConfig.dart';
import '../providers/authentication.dart';
import '../screens/login.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../miscellaneous/functions.dart' as func;
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String _userName;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  changeName() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Please Enter New Username:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextFormField(
            onChanged: (value) {
              _userName = value;
            },
            decoration: InputDecoration(
              labelText: "Enter your new username",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                Navigator.of(context).pop();
                try {
                  await Provider.of<Authentication>(context, listen: false).changeName(_userName, context);
                  await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser.uid).update({
                    'name': _userName,
                  });
                } catch (error) {
                  func.showError(error.toString(), context);
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                "Submit",
                style: TextStyle(
                  color: kBlue,
                  fontSize: SizeConfig.textScaleFactor * 20,
                )
              ),
            ),
          ],
        );
      }
    );
  }

  File _imageFile;
  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile.path);
      isLoading = true;
    });
    final firebaseStorageRef = FirebaseStorage.instance.ref("${_auth.currentUser.displayName}-${_auth.currentUser.uid}").child('profile_pic.png');
    final authInstance = Provider.of<Authentication>(context, listen: false);
    firebaseStorageRef.putFile(_imageFile).then((taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((value) async {
        await authInstance.attachImage(value, context).then((value) {
          setState(() {
            isLoading = false;
          });
        }).catchError((e){
          setState(() {
            isLoading = false;
          });
          func.showError(e.toString(), context);
        });
      }).catchError((e){
        setState(() {
          isLoading = false;
        });
        func.showError(e.toString(), context);
      });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
      func.showError(e.toString(), context);
    });
  }

  String _displayMessage;
  changePassword() async {
    try{
      await _auth.sendPasswordResetEmail(email: _auth.currentUser.email);
      _displayMessage = "Password reset link has been sent to " + _auth.currentUser.email + ". You will now be logged out.";
    } catch(e) {
      _displayMessage = e.toString();
    };
    setState(() {
      isLoading = false;
    });
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            _displayMessage,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authInstance = Provider.of<Authentication>(context, listen: false);
                authInstance.signOut().then((value){
                  Navigator.of(context).pushNamedAndRemoveUntil(Login.routeName, (route) => false);
                }).catchError((error) {
                  func.showError(error.toString(), context);
                });
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: kBlue,
                  fontSize: SizeConfig.textScaleFactor * 20,
                )
              ),
            ),
          ],
        );
      }
    );
  }

  deleteAccount() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Are you sure to delete your account?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: (){
                    setState(() {
                      isLoading = true;
                    });
                    final authInstance = Provider.of<Authentication>(context, listen: false);
                    final _uid = _auth.currentUser.uid;
                    final _name = _auth.currentUser.displayName;
                    final database = FirebaseFirestore.instance.collection('Users').doc(_uid);
                    _auth.currentUser.delete().then((value) async {
                      final storage =  FirebaseStorage.instance;
                      await storage.ref("${_name}-${_uid}").listAll().then((value) {
                        if(value != null) {
                          value.items.forEach((element) {
                            storage.ref(element.fullPath).delete();
                          });
                        }
                      });
                      database.collection("Categories").get().then((value){
                        value.docs.forEach((element) {
                          element.reference.delete();
                        });
                      });
                      database.collection("Tasks").get().then((value){
                        value.docs.forEach((element) {
                          element.reference.delete();
                        });
                      });
                      database.delete();
                      Navigator.of(context).pop();
                      setState(() {
                        isLoading = false;
                      });
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text(
                              "Account deleted successfully",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  authInstance.signOut().then((value){
                                    Navigator.of(context).pushNamedAndRemoveUntil(Login.routeName, (route) => false);
                                  }).catchError((error) {
                                    func.showError(error.toString(), context);
                                  });
                                },
                                child: Text(
                                  "Ok",
                                  style: TextStyle(
                                    color: kBlue,
                                    fontSize: SizeConfig.textScaleFactor * 20,
                                  )
                                ),
                              )
                            ]
                          );
                        }
                      );
                    }).catchError((error) {
                      Navigator.of(context).pop();
                      setState(() {
                        isLoading = false;
                      });
                      func.showError(error.toString(), context);
                    });
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
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight
              ),
              child: IntrinsicHeight(
                child: Container(
                  color: drawerbackground,
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.verticalBlockSize * 7,
                    horizontal: SizeConfig.horizontalBlockSize * 8
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading ?
                      CircularProgressIndicator() :
                      CircleAvatar(
                        radius: SizeConfig.horizontalBlockSize * 11,
                        backgroundImage: NetworkImage(
                          _auth.currentUser.photoURL ?? "https://i.pinimg.com/originals/cb/7d/48/cb7d48c589412612f5fd4a554e36a325.png",
                        ),
                      ),
                      MySpaces.vLargeGapInBetween,
                      Consumer<Authentication>(
                        builder: (ctx, auth, _) {
                          return Text(
                            _auth.currentUser.displayName,
                            style: MyFonts.bold.setColor(kWhite).letterSpace(3).size(SizeConfig.horizontalBlockSize * 7),
                          );
                        }
                      ),
                      MySpaces.vLargestGapInBetween,
                      GestureDetector(
                        onTap: () {
                          changeName();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: kGrey,
                            ),
                            MySpaces.hSmallestGapInBetween,
                            Text(
                              "Change Username",
                              style: MyFonts.medium.setColor(kWhite).size(SizeConfig.horizontalBlockSize * 4.2),
                            ),
                          ],
                        ),
                      ),
                      MySpaces.vGapInBetween,
                      GestureDetector(
                        onTap: () {
                          pickImage();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: kGrey,
                            ),
                            MySpaces.hSmallestGapInBetween,
                            Text(
                              "Change Profile Picture",
                              style: MyFonts.medium.setColor(kWhite).size(SizeConfig.horizontalBlockSize * 4.2),
                            ),
                          ],
                        ),
                      ),
                      MySpaces.vGapInBetween,
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          changePassword();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: kGrey,
                            ),
                            MySpaces.hSmallestGapInBetween,
                            Text(
                              "Change Password",
                              style: MyFonts.medium.setColor(kWhite).size(SizeConfig.horizontalBlockSize * 4.2),
                            ),
                          ],
                        ),
                      ),
                      MySpaces.vGapInBetween,
                      GestureDetector(
                        onTap: () {
                          deleteAccount();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: kGrey,
                            ),
                            MySpaces.hSmallestGapInBetween,
                            Text(
                              "Delete Account",
                              style: MyFonts.medium.setColor(kWhite).size(SizeConfig.horizontalBlockSize * 4.2),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final authInstance = Provider.of<Authentication>(context, listen: false);
                          authInstance.signOut().then((value) {
                            Navigator.of(context).pushNamedAndRemoveUntil(Login.routeName, (route) => false);
                          }).catchError((error) {
                            func.showError(error.toString(), context);
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.white
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0
                              ),
                              child: Text(
                                'Log out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConfig.horizontalBlockSize * 5
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
