import '../models/task.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../miscellaneous/notifications.dart';

extension DateCompare on DateTime {
  bool isDateSame(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class Tasks with ChangeNotifier {

  DateTime selectedDate = DateTime.now();

  List<Group> _categories = [];

  List<Group> get categories {
    return [..._categories];
  }

  List<Task> _tasks = [];

  List<Task> get tasks {
    return [..._tasks];
  }

  void addCategory(Group grp) {
    if (!_categories.contains(grp)) {
      _categories.add(grp);
    }
  }

  void deleteCategory(Group category) async {
    List<Task> tasks = _tasks.where((task) => task.category.title == category.title).toList();
    tasks.forEach((task) {
      deleteTask(task);
    });
    _categories.remove(category);
  }

  List<Task> availableTasks(Group category) {
    List<Task> finalList = [];
    finalList = todaysTask.where((task) => task.category.title == category.title).toList();
    return finalList;
  }

  List<Task> get todaysTask {
    List<Task> finalList = [];
    _tasks.forEach((task) {
      if (task.date.isDateSame(selectedDate)) {
        finalList.add(task);
      }
    });
    return finalList;
  }

  void addTask(Task task) {
    if (!_tasks.contains(task)) {
      _tasks.add(task);
      if(task.remind=='yes'){
        NotificationService().scheduleNotification(task);
      }
    }
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    if(task.remind=='yes') {
      NotificationService().cancelNotification(task);
    }
  }

  void updateTask(Task task, Task newtask) {
    _tasks[_tasks.indexOf(task)] = newtask;
    if(task.remind=='yes') {
      NotificationService().cancelNotification(task);
    }
    if(newtask.remind=='yes') {
      NotificationService().scheduleNotification(newtask);
    }
  }

  void changeSelectedDate(DateTime newDate) {
    selectedDate = newDate;
  }

  void fetchAndSet(bool isLogin) async {
    _tasks.clear();
    _categories.clear();
    FirebaseFirestore.instance.collection('Users')
      .doc(FirebaseAuth.instance.currentUser.uid).collection('Tasks')
      .get().then((value){
        value.docs.forEach((element) {
          Task _currTask = Task.fromMap(element.data());
          _tasks.add(_currTask);
          if(_currTask.remind=='yes' && isLogin) {
            NotificationService().scheduleNotification(_currTask);
          }
        });
    });
    FirebaseFirestore.instance.collection('Users')
      .doc(FirebaseAuth.instance.currentUser.uid).collection('Categories')
      .get().then((value){
        value.docs.forEach((element) {
          _categories.add(Group.fromMap(element.data()));
        });
    });
  }
}
