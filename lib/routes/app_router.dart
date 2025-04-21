import 'package:flutter/material.dart';
import 'package:muststudy/screens/login_screen.dart';
import 'package:muststudy/screens/main_screen.dart';
import 'package:muststudy/screens/achievement_screen.dart';
import 'package:muststudy/screens/achievement_list_screen.dart';
import 'package:muststudy/screens/learning_resources_screen.dart';
import 'package:muststudy/screens/resource_details.dart';
import 'package:muststudy/screens/forum_screen.dart';
import 'package:muststudy/screens/problem_details.dart';
import 'package:muststudy/screens/profile_screen.dart';
import 'package:muststudy/screens/settings_screen.dart';

// 路由参数类
class RouteArguments {
  final dynamic data;
  final Map<String, dynamic>? params;
  
  RouteArguments({this.data, this.params});
  
  static RouteArguments resourceDetails(dynamic resource) {
    return RouteArguments(data: resource);
  }
  
  static RouteArguments problemDetails(dynamic problem) {
    return RouteArguments(data: problem);
  }
}

// 路由守卫
class RouteGuard {
  static bool _isLoggedIn = false;
  
  static bool canActivate(String routeName) {
    final publicRoutes = [RouteNames.login];
    return publicRoutes.contains(routeName) || _isLoggedIn;
  }
  
  static void setLoggedIn(bool value) {
    _isLoggedIn = value;
  }
}

// 路由名称
class RouteNames {
  static const String login = '/login';
  static const String home = '/home';
  static const String achievements = '/achievements';
  static const String achievementList = '/achievements/list';
  static const String resources = '/resources';
  static const String resourceDetails = '/resources/details';
  static const String forum = '/forum';
  static const String problemDetails = '/forum/problem';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String favorites = '/profile/favorites';
  static const String history = '/profile/history';
  static const String notes = '/profile/notes';
}

// 路由过渡动画
class RouteTransitions {
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  static PageRouteBuilder slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// 路由配置
class AppRouter {
  static const String initialRoute = RouteNames.login;
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (!RouteGuard.canActivate(settings.name ?? '')) {
      return RouteTransitions.fadeTransition(const LoginScreen());
    }
    
    switch (settings.name) {
      case RouteNames.login:
        return RouteTransitions.fadeTransition(const LoginScreen());
      case RouteNames.home:
        return RouteTransitions.slideTransition(const MainScreen());
      case RouteNames.achievements:
        return RouteTransitions.slideTransition(const AchievementScreen());
      case RouteNames.achievementList:
        return RouteTransitions.slideTransition(const AchievementListScreen());
      case RouteNames.resources:
        return RouteTransitions.slideTransition(const LearningResourcesScreen());
      case RouteNames.resourceDetails:
        final args = settings.arguments as RouteArguments;
        return RouteTransitions.slideTransition(
          ResourceDetails(resource: args.data),
        );
      case RouteNames.forum:
        return RouteTransitions.slideTransition(const ForumScreen());
      case RouteNames.problemDetails:
        final args = settings.arguments as RouteArguments;
        return RouteTransitions.slideTransition(
          ProblemDetails(problem: args.data),
        );
      case RouteNames.profile:
        return RouteTransitions.slideTransition(const ProfileScreen());
      case RouteNames.settings:
        return RouteTransitions.slideTransition(const SettingsScreen());
      default:
        return RouteTransitions.fadeTransition(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 