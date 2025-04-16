import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'app_router.dart';
import '../services/navigation_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static Future<void> initialize() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    
    return MaterialApp(
      title: 'Must Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorKey: navigationService.navigatorKey,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
} 