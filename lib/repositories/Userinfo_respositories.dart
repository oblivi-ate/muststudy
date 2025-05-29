import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserinfoRepository {
  static const String _userStatsCache = 'user_statistics';
  static bool _initialized = false;
  
  // 确保SharedPreferences正确初始化
  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences初始化成功');
      _initialized = true;
      
      // 检查数据存储状态
      final keys = prefs.getKeys();
      print('当前存储的键值: $keys');
      
      // 检查用户统计数据键
      final statsKeys = keys.where((key) => key.startsWith(_userStatsCache)).toList();
      print('用户统计数据键: $statsKeys');
      
      return true;
    } catch (e) {
      print('SharedPreferences初始化失败: $e');
      return false;
    }
  }
  
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
      // 确保初始化
      await ensureInitialized();
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_userStatsCache}_$userId';
      print('尝试读取用户统计数据，缓存键：$cacheKey');
      final data = prefs.getString(cacheKey);
      
      if (data != null) {
        print('找到用户统计数据：$data');
        return Map<String, dynamic>.from(json.decode(data));
      }
      
      // 如果没有数据，创建默认统计
      final defaultStats = {
        'userId': userId,
        'studyHours': 0,
        'solvedProblems': 0,
        'achievements': 0,
      };
      
      print('未找到用户数据，创建默认数据：$defaultStats');
      // 确保同步写入
      await prefs.setString(cacheKey, json.encode(defaultStats));
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
      // 确保初始化
      await ensureInitialized();
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_userStatsCache}_$userId';
      final stats = await getUserStatistics(userId);
      
      stats['solvedProblems'] = (stats['solvedProblems'] ?? 0) + increment;
      
      final success = await prefs.setString(cacheKey, json.encode(stats));
      if (success) {
      print('更新已解题目数量成功，当前数量: ${stats['solvedProblems']}');
      } else {
        print('警告: 更新已解题目数量可能未成功保存');
      }
      return success;
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
      // 确保初始化
      await ensureInitialized();
      
      // 如果传入的小时数为0或负数，直接返回成功但不更新
      if (hours <= 0) {
        print('更新学习时长：传入了无效的时长 $hours，不进行更新');
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_userStatsCache}_$userId';
      final stats = await getUserStatistics(userId);
      
      // 转换为两位小数，避免过小的数值
      final roundedHours = double.parse(hours.toStringAsFixed(2));
      
      // 更新学习时长
      double currentHours = (stats['studyHours'] ?? 0).toDouble();
      stats['studyHours'] = currentHours + roundedHours;
      
      // 确保数据被同步写入
      final success = await prefs.setString(cacheKey, json.encode(stats));
      
      if (success) {
        print('更新学习时长成功，键：$cacheKey，当前时长: ${stats['studyHours']}，本次增加: $roundedHours');
        // 额外检查是否写入成功
        final verification = prefs.getString(cacheKey);
        if (verification != null) {
          final verifiedStats = json.decode(verification);
          print('验证数据：studyHours = ${verifiedStats['studyHours']}');
        } else {
          print('警告：无法验证数据写入');
        }
      } else {
        print('警告：数据可能未成功写入');
      }
      
      return success;
    } catch (e) {
      print('更新学习时长失败: $e');
      return false;
    }
  }
  
  // 更新成就数量
  Future<bool> updateAchievements(int userId, {int increment = 1}) async {
    try {
      // 确保初始化
      await ensureInitialized();
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_userStatsCache}_$userId';
      final stats = await getUserStatistics(userId);
      
      stats['achievements'] = (stats['achievements'] ?? 0) + increment;
      
      final success = await prefs.setString(cacheKey, json.encode(stats));
      if (success) {
      print('更新成就数量成功，当前数量: ${stats['achievements']}');
      } else {
        print('警告: 更新成就数量可能未成功保存');
      }
      return success;
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
          
          // 更新喜马拉雅收藏家成就
          await _updateHimalayaCollectorAchievement(userId, bookmarksList.length);
          
          return updateResponse.success;
        }
        return true; // 已经收藏了
      } else {
        // 创建新的收藏记录
        final userBookmarks = ParseObject('UserBookmarks')
          ..set('userId', userId)
          ..set('bookmarkedQuestions', [questionId]);
        final createResponse = await userBookmarks.save();
        
        // 更新喜马拉雅收藏家成就
        await _updateHimalayaCollectorAchievement(userId, 1);
        
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

  // 添加收藏资源方法
  Future<bool> bookmarkResource(int userId, String resourceId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserResourceBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        // 更新现有收藏
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedResources') ?? [];
        
        if (!bookmarksList.contains(resourceId)) {
          bookmarksList.add(resourceId);
          userBookmarks.set('bookmarkedResources', bookmarksList);
          final updateResponse = await userBookmarks.save();
          
          // 更新喜马拉雅收藏家成就
          await _updateHimalayaCollectorAchievement(userId, bookmarksList.length);
          
          return updateResponse.success;
        }
        return true; // 已经收藏了
      } else {
        // 创建新的收藏记录
        final userBookmarks = ParseObject('UserResourceBookmarks')
          ..set('userId', userId)
          ..set('bookmarkedResources', [resourceId]);
        final createResponse = await userBookmarks.save();
        
        // 更新喜马拉雅收藏家成就
        await _updateHimalayaCollectorAchievement(userId, 1);
        
        return createResponse.success;
      }
    } catch (e) {
      print('添加资源收藏失败: $e');
      return false;
    }
  }
  
  // 取消收藏资源方法
  Future<bool> unbookmarkResource(int userId, String resourceId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserResourceBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedResources') ?? [];
        
        if (bookmarksList.contains(resourceId)) {
          bookmarksList.remove(resourceId);
          userBookmarks.set('bookmarkedResources', bookmarksList);
          final updateResponse = await userBookmarks.save();
          return updateResponse.success;
        }
        return true; // 资源已经不在收藏列表中
      }
      return false;
    } catch (e) {
      print('取消资源收藏失败: $e');
      return false;
    }
  }
  
  // 获取用户资源收藏列表
  Future<List<String>> getUserResourceBookmarks(int userId) async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('UserResourceBookmarks'))
        ..whereEqualTo('userId', userId);
      final response = await query.query();
      
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        final userBookmarks = response.results!.first as ParseObject;
        final bookmarksList = userBookmarks.get<List>('bookmarkedResources');
        if (bookmarksList != null) {
          return List<String>.from(bookmarksList);
        }
      }
      return [];
    } catch (e) {
      print('获取用户资源收藏失败: $e');
      return [];
    }
  }
  
  // 检查资源是否已收藏
  Future<bool> isResourceBookmarked(int userId, String resourceId) async {
    try {
      final bookmarks = await getUserResourceBookmarks(userId);
      return bookmarks.contains(resourceId);
    } catch (e) {
      print('检查资源收藏状态失败: $e');
      return false;
    }
  }
  
  // 更新喜马拉雅收藏家成就进度
  Future<void> _updateHimalayaCollectorAchievement(int userId, int bookmarksCount) async {
    try {
      // 获取SharedPreferences实例
      final prefs = await SharedPreferences.getInstance();
      
      // 喜马拉雅收藏家成就的ID (根据实际情况调整)
      const himalayaAchievementId = 'himalaya_collector';
      
      // 成就的总目标
      const totalGoal = 30;
      
      // 获取当前资源收藏数量和题目收藏数量（总是重新获取最新数据）
      final resourceBookmarks = await getUserResourceBookmarks(userId);
      final questionBookmarks = await getUserBookmarks(userId);
      
      // 计算总的收藏数量
      final totalBookmarksCount = resourceBookmarks.length + questionBookmarks.length;
      
      // 获取当前成就进度
      final achievementKey = 'achievement_${himalayaAchievementId}_$userId';
      final currentProgress = prefs.getInt(achievementKey) ?? 0;
      
      // 如果总的收藏数量与当前记录的进度不同，更新进度
      if (totalBookmarksCount != currentProgress) {
        // 更新进度，但不超过总目标
        final newProgress = totalBookmarksCount < totalGoal ? totalBookmarksCount : totalGoal;
        
        // 保存新进度
        await prefs.setInt(achievementKey, newProgress);
        
        print('喜马拉雅收藏家成就进度更新: $newProgress/$totalGoal (资源: ${resourceBookmarks.length}, 题目: ${questionBookmarks.length})');
        print('资源收藏ID列表: $resourceBookmarks');
        print('题目收藏ID列表: $questionBookmarks');
        
        // 检查里程碑达成情况
        if (newProgress >= 10 && currentProgress < 10) {
          print('达成里程碑: 第一个营地');
          // 这里可以添加成就解锁通知逻辑
        }
        
        if (newProgress >= 20 && currentProgress < 20) {
          print('达成里程碑: 第二个营地');
          // 这里可以添加成就解锁通知逻辑
        }
        
        if (newProgress >= 30 && currentProgress < 30) {
          print('达成里程碑: 山顶');
          // 这里可以添加成就解锁通知逻辑
        }
      }
    } catch (e) {
      print('更新喜马拉雅收藏家成就进度失败: $e');
    }
  }

  // 同步喜马拉雅收藏家成就进度
  Future<void> syncHimalayaCollectorAchievement(int userId) async {
    try {
      // 获取当前资源收藏数量和题目收藏数量
      final resourceBookmarks = await getUserResourceBookmarks(userId);
      final questionBookmarks = await getUserBookmarks(userId);
      
      // 计算总的收藏数量
      final totalBookmarksCount = resourceBookmarks.length + questionBookmarks.length;
      
      print('同步喜马拉雅收藏家成就 - 用户ID: $userId');
      print('资源收藏数量: ${resourceBookmarks.length}，收藏ID列表: $resourceBookmarks');
      print('题目收藏数量: ${questionBookmarks.length}，收藏ID列表: $questionBookmarks');
      print('总收藏数量: $totalBookmarksCount');
      
      // 重置成就进度
      final prefs = await SharedPreferences.getInstance();
      const himalayaAchievementId = 'himalaya_collector';
      final achievementKey = 'achievement_${himalayaAchievementId}_$userId';
      await prefs.setInt(achievementKey, totalBookmarksCount);
      
      print('已重置喜马拉雅收藏家成就进度为: $totalBookmarksCount');
    } catch (e) {
      print('同步喜马拉雅收藏家成就进度失败: $e');
    }
  }
}