import 'package:muststudy/repositories/Userinfo_respositories.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/achievement_list_screen.dart';
import 'screens/main_screen.dart';
import 'screens/resource_details.dart';
import 'screens/problem_details.dart';
import 'screens/login_screen.dart';
import 'util/places.dart';
import 'theme/app_theme.dart';
import 'models/resource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Parse
  try {
    await Parse().initialize(
      'B3nFoESSc6GUUQHgFCmFzvf7RQKliagLarf7Rs3g',
      'https://parseapi.back4app.com',
      clientKey: 'Y43iPlZRj7XgjqTR56PG48PAxhnPgf4QeeSMtWIv',
      debug: true,
    );
    print('Parse 初始化成功');
  } catch (e) {
    print('Parse 初始化失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Must Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
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
