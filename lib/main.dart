import './providers/tasks.dart';
import './screens/create_task.dart';
import './screens/create_category.dart';
import './screens/calendar_screen.dart';
import './screens/login.dart';
import './screens/homepage.dart';
import './screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/authentication.dart';
import './screens/splash_screen.dart';
import './miscellaneous/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Authentication(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Tasks(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {
          HomePage.routeName: (ctx) => HomePage(),
          SignUp.routeName: (ctx) => SignUp(),
          Login.routeName: (ctx) => Login(),
          EditCategoryScreen.routeName: (ctx) => EditCategoryScreen(),
          CreateNewTask.routeName: (ctx) => CreateNewTask(),
          CalendarScreen.routeName: (ctx) => CalendarScreen(),
        },
      ),
    );
  }
}
