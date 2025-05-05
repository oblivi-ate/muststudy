import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserinfoRepository {
  static const String _userStatsCache = 'user_statistics';
  
  Future<void> createUserinfoItem(int id, String name, String password) async {
    final userinfo = ParseObject('Userinfo')
      ..set('u_id', id)
      ..set('u_name', name)
      ..set('u_password', password);
    final response = await userinfo.save();
    if (response.success) {
      print('Userinfo item created successfully');
    } else {
      print('Failed to create Userinfo item: ${response.error?.message}');
    }
  }

  Future<List<ParseObject>?> fetchUserinfo() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return null;
  }

  Future<void> updateUserinfo(int id, String newName, String newPassword) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
      ..whereEqualTo('u_id', id);
    final response = await query.query();
    if (response.success && response.results != null) {
      final user = response.results!.first as ParseObject;
      user
        ..set('u_name', newName)
        ..set('u_password', newPassword);
      await user.save();
    }
  }

  Future<void> deleteUserinfo(int id) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
      ..whereEqualTo('u_id', id);
    final response = await query.query();
    if (response.success && response.results != null) {
      final user = response.results!.first as ParseObject;
      await user.delete();
    }
  }

  Future<String> getUserName(int userId) async {
    try {
      if (userId == 1) {
        return 'test';
      } else if (userId == 2) {
        return 'admin';
      } else if (userId == 3) {
        return 'guest';
      }
      return '用户$userId';
    } catch (e) {
      print('获取用户名失败: $e');
      return '未知用户';
    }
  }

  // 获取用户统计数据
  Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('${_userStatsCache}_$userId');
      
      if (data != null) {
        return Map<String, dynamic>.from(json.decode(data));
      }
      
      // 如果没有数据，创建默认统计
      final defaultStats = {
        'userId': userId,
        'studyHours': 0,
        'solvedProblems': 0,
        'achievements': 0,
      };
      
      await prefs.setString('${_userStatsCache}_$userId', json.encode(defaultStats));
      return defaultStats;
    } catch (e) {
      print('获取用户统计失败: $e');
      return {
        'userId': userId,
        'studyHours': 0,
        'solvedProblems': 0,
        'achievements': 0,
      };
    }
  }
  
  // 更新已解题目数量
  Future<bool> updateSolvedProblems(int userId, {int increment = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await getUserStatistics(userId);
      
      stats['solvedProblems'] = (stats['solvedProblems'] ?? 0) + increment;
      
      await prefs.setString('${_userStatsCache}_$userId', json.encode(stats));
      print('更新已解题目数量成功，当前数量: ${stats['solvedProblems']}');
      return true;
    } catch (e) {
      print('更新已解题目数量失败: $e');
      return false;
    }
  }
  
  // 计算用户等级
  String getUserLevel(int solvedProblems) {
    if (solvedProblems >= 500) {
      return 'Lv.10 专家';
    } else if (solvedProblems >= 400) {
      return 'Lv.9 大师';
    } else if (solvedProblems >= 300) {
      return 'Lv.8 高级学者';
    } else if (solvedProblems >= 200) {
      return 'Lv.7 学者';
    } else if (solvedProblems >= 150) {
      return 'Lv.6 高级学习者';
    } else if (solvedProblems >= 100) {
      return 'Lv.5 勤奋学习者';
    } else if (solvedProblems >= 70) {
      return 'Lv.4 进阶者';
    } else if (solvedProblems >= 40) {
      return 'Lv.3 实践者';
    } else if (solvedProblems >= 10) {
      return 'Lv.2 新手';
    } else {
      return 'Lv.1 初学者';
    }
  }
  
  // 更新学习时长
  Future<bool> updateStudyHours(int userId, double hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await getUserStatistics(userId);
      
      stats['studyHours'] = (stats['studyHours'] ?? 0) + hours;
      
      await prefs.setString('${_userStatsCache}_$userId', json.encode(stats));
      print('更新学习时长成功，当前时长: ${stats['studyHours']}');
      return true;
    } catch (e) {
      print('更新学习时长失败: $e');
      return false;
    }
  }
  
  // 更新成就数量
  Future<bool> updateAchievements(int userId, {int increment = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await getUserStatistics(userId);
      
      stats['achievements'] = (stats['achievements'] ?? 0) + increment;
      
      await prefs.setString('${_userStatsCache}_$userId', json.encode(stats));
      print('更新成就数量成功，当前数量: ${stats['achievements']}');
      return true;
    } catch (e) {
      print('更新成就数量失败: $e');
      return false;
    }
  }

  // 添加查询用户收藏的方法
  Future<List<int>> getUserBookmarks(int userId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedQuestions');
        if (bookmarksList != null) {
          return List<int>.from(bookmarksList);
        }
      }
      return [];
    } catch (e) {
      print('获取用户收藏失败: $e');
      return [];
    }
  }
  
  // 添加收藏题目方法
  Future<bool> bookmarkQuestion(int userId, int questionId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        // 更新现有收藏
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedQuestions') ?? [];
        
        if (!bookmarksList.contains(questionId)) {
          bookmarksList.add(questionId);
          userBookmarks.set('bookmarkedQuestions', bookmarksList);
          final updateResponse = await userBookmarks.save();
          return updateResponse.success;
        }
        return true; // 已经收藏了
      } else {
        // 创建新的收藏记录
        final userBookmarks = ParseObject('UserBookmarks')
          ..set('userId', userId)
          ..set('bookmarkedQuestions', [questionId]);
        final createResponse = await userBookmarks.save();
        return createResponse.success;
      }
    } catch (e) {
      print('添加收藏失败: $e');
      return false;
    }
  }
  
  // 取消收藏题目方法
  Future<bool> unbookmarkQuestion(int userId, int questionId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedQuestions') ?? [];
        
        if (bookmarksList.contains(questionId)) {
          bookmarksList.remove(questionId);
          userBookmarks.set('bookmarkedQuestions', bookmarksList);
          final updateResponse = await userBookmarks.save();
          return updateResponse.success;
        }
        return true; // 题目已经不在收藏列表中
      }
      return false;
    } catch (e) {
      print('取消收藏失败: $e');
      return false;
    }
  }
  
  // 检查题目是否已收藏
  Future<bool> isQuestionBookmarked(int userId, int questionId) async {
    try {
      final bookmarks = await getUserBookmarks(userId);
      return bookmarks.contains(questionId);
    } catch (e) {
      print('检查收藏状态失败: $e');
      return false;
    }
  }

  // 获取当前用户ID
  Future<int> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('current_user_id') ?? 1; // 默认返回用户ID 1
    } catch (e) {
      print('获取用户ID失败: $e');
      return 1; // 出错时返回默认用户ID
    }
  }

  // 设置当前用户ID
  Future<void> setUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', userId);
    } catch (e) {
      print('设置用户ID失败: $e');
    }
  }
}