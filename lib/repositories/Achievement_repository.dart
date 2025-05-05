import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AchievementRepository {
  static const String _achievementsCache = 'local_achievements';
  
  // 初始化默认成就数据
  Future<void> initializeDefaultAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_achievementsCache);
    
    if (existingData == null) {
      final defaultAchievements = [
        {
          'id': 1,
          'title': '初出茅庐',
          'description': '完成第一道编程题',
          'icon': 'assets/icons/achievement_beginner.png',
          'condition': '完成1道题目',
          'reward': '经验值+10',
          'type': '入门',
          'progress': 0,
          'total': 1,
          'unlocked': false,
        },
        {
          'id': 2,
          'title': '勤学苦练',
          'description': '完成10道编程题',
          'icon': 'assets/icons/achievement_diligent.png',
          'condition': '完成10道题目',
          'reward': '经验值+50',
          'type': '进阶',
          'progress': 0,
          'total': 10,
          'unlocked': false,
        },
        {
          'id': 3,
          'title': '算法达人',
          'description': '完成所有算法类题目',
          'icon': 'assets/icons/achievement_algorithm.png',
          'condition': '完成全部算法题',
          'reward': '经验值+100',
          'type': '专业',
          'progress': 0,
          'total': 5,
          'unlocked': false,
        },
        {
          'id': 4,
          'title': '设计大师',
          'description': '完成所有设计模式题目',
          'icon': 'assets/icons/achievement_design.png',
          'condition': '完成全部设计模式题',
          'reward': '经验值+100',
          'type': '专业',
          'progress': 0,
          'total': 5,
          'unlocked': false,
        },
        {
          'id': 5,
          'title': '分布式专家',
          'description': '完成所有分布式系统题目',
          'icon': 'assets/icons/achievement_distributed.png',
          'condition': '完成全部分布式系统题',
          'reward': '经验值+150',
          'type': '高级',
          'progress': 0,
          'total': 3,
          'unlocked': false,
        }
      ];
      
      await prefs.setString(_achievementsCache, json.encode(defaultAchievements));
      print('Default achievements initialized');
    }
  }

  // 获取所有成就
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_achievementsCache);
      
      if (data == null) {
        await initializeDefaultAchievements();
        final newData = prefs.getString(_achievementsCache);
        return newData != null 
            ? List<Map<String, dynamic>>.from(json.decode(newData))
            : [];
      }
      
      return List<Map<String, dynamic>>.from(json.decode(data));
    } catch (e) {
      print('获取成就失败: $e');
      return [];
    }
  }

  // 更新成就进度
  Future<void> updateAchievementProgress(int achievementId, int progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievements = await getAchievements();
      
      final index = achievements.indexWhere((a) => a['id'] == achievementId);
      if (index != -1) {
        achievements[index]['progress'] = progress;
        if (progress >= achievements[index]['total']) {
          achievements[index]['unlocked'] = true;
        }
        
        await prefs.setString(_achievementsCache, json.encode(achievements));
      }
    } catch (e) {
      print('更新成就进度失败: $e');
    }
  }

  // 获取用户已解锁的成就
  Future<List<Map<String, dynamic>>> getUnlockedAchievements() async {
    try {
      final achievements = await getAchievements();
      return achievements.where((a) => a['unlocked'] == true).toList();
    } catch (e) {
      print('获取已解锁成就失败: $e');
      return [];
    }
  }

  // 检查并更新成就状态
  Future<void> checkAndUpdateAchievements(int userId, int solvedProblems) async {
    try {
      final achievements = await getAchievements();
      
      for (var achievement in achievements) {
        if (achievement['type'] == '入门' || achievement['type'] == '进阶') {
          await updateAchievementProgress(achievement['id'], solvedProblems);
        }
      }
    } catch (e) {
      print('检查成就状态失败: $e');
    }
  }
}