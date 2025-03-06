import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/achievement_list_screen.dart';
import 'screens/main_screen.dart';
import 'screens/resource_details.dart';
import 'screens/problem_details.dart';
import 'util/places.dart';
import 'theme/app_theme.dart';
import 'models/resource.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Must Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainScreen(),
      routes: {
        '/achievements': (context) => const AchievementScreen(),
        '/achievements/list': (context) => const AchievementListScreen(),
      },
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/resource') {
          final resource = settings.arguments as Resource;
          return MaterialPageRoute(
            builder: (context) => ResourceDetails(resource: resource),
          );
        } else if (settings.name == '/problem') {
          final problem = settings.arguments as Problem;
          return MaterialPageRoute(
            builder: (context) => ProblemDetails(problem: problem),
          );
        }
        return null;
      },
    );
  }
}
