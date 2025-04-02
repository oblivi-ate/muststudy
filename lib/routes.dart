import 'package:flutter/material.dart';
import 'screens/achievements_screen.dart';
import 'screens/achievement_list_screen.dart';

class AppRoutes {
  static const String achievements = '/achievements';
  static const String achievementList = '/achievements/list';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      achievements: (context) => const AchievementsScreen(),
      achievementList: (context) => const AchievementListScreen(),
    };
  }
} 