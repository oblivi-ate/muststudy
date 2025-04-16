import 'package:flutter/material.dart';
import 'package:muststudy/routes/route_names.dart';
import 'package:muststudy/routes/route_guard.dart';
import 'package:muststudy/routes/route_transitions.dart';
import 'package:muststudy/routes/route_arguments.dart';
import 'package:muststudy/screens/login_screen.dart';
import 'package:muststudy/screens/main_screen.dart';
import 'package:muststudy/screens/achievement_screen.dart';
import 'package:muststudy/screens/achievement_list_screen.dart';
import 'package:muststudy/screens/learning_resources_screen.dart';
import 'package:muststudy/screens/resource_details.dart';
import 'package:muststudy/screens/forum_screen.dart';
import 'package:muststudy/screens/problem_details.dart';
import 'package:muststudy/screens/profile_screen.dart';

class AppRouter {
  static const String initialRoute = RouteNames.login;
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 检查路由权限
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