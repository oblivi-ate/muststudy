import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/resource_details.dart';
import 'screens/problem_details.dart';
import 'util/places.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MustStudy',
      theme: appTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/resource') {
          final resource = settings.arguments as StudyResource;
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
