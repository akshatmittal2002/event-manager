import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../miscellaneous/functions.dart' as func;
import '../miscellaneous/notifications.dart';

class Authentication with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  signUp(String name, String email, String password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (user != null) {
        await _auth.currentUser.updateDisplayName(name);
      }
    } catch (e) {
      throw e;
    }
  }

  signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      NotificationService().cancelAllNotifications();
    } catch (error) {
      throw error;
    }
  }

  attachImage(String url, BuildContext context) async {
    try {
      await _auth.currentUser.updatePhotoURL(url);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Profile Photo Updated"
        )
      ));
    } catch (e) {
      throw e;
    }
  }

  changeName(String newName, BuildContext context) async {
    try {
      if (newName.isNotEmpty) {
        await _auth.currentUser.updateDisplayName(newName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Name updated"
          )
        ));
      } else {
        func.showError("Username cannot be empty", context);
      }
    } catch (e) {
      throw e;
    }
  }

}
