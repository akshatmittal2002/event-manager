import 'dart:convert';
import '../models/group.dart';
import 'package:flutter/material.dart';

extension passTime on TimeOfDay {
  String toExtractableString() {
    return json.encode({
      'hour': this.hour,
      'minute': this.minute,
    });
  }
}

class Task {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Group category;
  final String remind;

  Task({
    this.id,
    this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.category,
    this.remind,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toExtractableString(),
      'endTime': endTime.toExtractableString(),
      'category': json.encode({
        "id": category.id,
        'title': category.title,
        'color': category.color.value,
      }),
      'remind': remind,
    };
  }

  Task addId(String id) {
    return Task(
      id: id,
      title: this.title,
      date: this.date,
      startTime: this.startTime,
      endTime: this.endTime,
      category: this.category,
      remind: this.remind,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final startTimeData = json.decode(map['startTime']) as Map<String, dynamic>;
    final endTimeData = json.decode(map['endTime']) as Map<String, dynamic>;
    final categoryData = json.decode(map['category']);
    return Task(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: startTimeData['hour'],
        minute: startTimeData['minute']
      ),
      endTime: TimeOfDay(
        hour: endTimeData['hour'],
        minute: endTimeData['minute']
      ),
      category: Group(
        id: categoryData['id'],
        title: categoryData['title'],
        color: Color(categoryData['color']),
      ),
      remind: map['remind'],
    );
  }

}
