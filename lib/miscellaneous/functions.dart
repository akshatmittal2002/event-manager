import 'package:flutter/material.dart';

String timeMode(time) {
  if (time == null) {
    return "";
  }
  if (time.periodOffset == 0) {
    return " AM";
  } else {
    return " PM";
  }
}

String minutes(time) {
  if (time == null) {
    return "";
  }
  if (time.minute < 10) {
    return "0${time.minute}";
  } else {
    return "${time.minute}";
  }
}

String hours(time) {
  if (time == null) {
    return "";
  }
  if (time.hour == time.periodOffset) {
    return '12';
  }
  return "${time.hour - time.periodOffset}";
}

showError(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'ERROR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )
        ),
        content: Text(
          message
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Ok'
            )
          )
        ],
      );
    },
  );
}
