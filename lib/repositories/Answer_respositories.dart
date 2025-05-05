import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnswerRespositories {
  static const String _answersCache = 'local_answers';
  
  // 初始化默认评论数据
  Future<void> initializeDefaultAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_answersCache);
    
    if (existingData == null) {
      final defaultAnswers = [
        // 题目1的评论（排序算法）
        {
          'a_id': 1,
          'ainfo': '对于大规模数据集，我建议使用快速排序的优化版本。关键是选择好的轴点策略，比如三数取中法，并且在数据量较小时切换到插入排序。对于重复元素多的情况，可以使用三路快排。',
          'uid': 1,
          'alike': 8,
          'question_id': 1,
          'is_solved': false,
          'created_at': '2024-03-20T10:30:00.000Z'
        },
        {
          'a_id': 2,
          'ainfo': '我实现了一个混合排序算法，在数据量大时使用并行的归并排序，小数据量时使用快速排序。测试结果显示，在8核CPU上处理1亿条数据只需要不到1分钟。关键是要处理好并行排序的数据分片和合并策略。',
          'uid': 2,
          'alike': 12,
          'question_id': 1,
          'is_solved': true,
          'created_at': '2024-03-20T11:30:00.000Z'
        },
        
        // 题目2的评论（观察者模式）
        {
          'a_id': 3,
          'ainfo': '实现观察者模式时，要注意避免内存泄漏。我建议使用弱引用来存储观察者对象，并在被观察者发送通知时清理已失效的观察者。另外，对于异步事件，最好使用事件队列来处理。',
          'uid': 1,
          'alike': 6,
          'question_id': 2,
          'is_solved': false,
          'created_at': '2024-03-20T12:30:00.000Z'
        },
        {
          'a_id': 4,
          'ainfo': '我在项目中使用了带优先级的事件系统，核心是用优先级队列来存储事件。对于高优先级事件，会立即中断当前的事件处理。这在实时性要求高的场景下非常有用。',
          'uid': 3,
          'alike': 9,
          'question_id': 2,
          'is_solved': true,
          'created_at': '2024-03-20T13:30:00.000Z'
        },
        
        // 题目3的评论（分布式一致性）
        {
          'a_id': 5,
          'ainfo': '实现Raft算法时，最关键的是处理好网络分区的情况。我的建议是实现一个保守的领导者选举策略，确保在网络分区时不会出现双主节点的情况。另外，日志复制要使用批量方式来提高性能。',
          'uid': 2,
          'alike': 15,
          'question_id': 3,
          'is_solved': true,
          'created_at': '2024-03-20T14:30:00.000Z'
        },
        {
          'a_id': 6,
          'ainfo': '我在实现中加入了快照机制，定期对状态机做快照，并压缩日志。这样可以加快新节点加入时的数据同步速度，也能避免日志无限增长的问题。测试显示，启用快照后，系统恢复时间减少了80%。',
          'uid': 1,
          'alike': 11,
          'question_id': 3,
          'is_solved': false,
          'created_at': '2024-03-20T15:30:00.000Z'
        }
      ];
      
      await prefs.setString(_answersCache, json.encode(defaultAnswers));
      print('Default answers initialized');
    }
  }

  // 获取本地存储的所有回答
  Future<List<Map<String, dynamic>>> _getLocalAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_answersCache);
    if (data != null) {
      return List<Map<String, dynamic>>.from(json.decode(data));
    }
    
    // 如果没有数据，初始化默认数据
    await initializeDefaultAnswers();
    final newData = prefs.getString(_answersCache);
    return newData != null 
        ? List<Map<String, dynamic>>.from(json.decode(newData))
        : [];
  }

  // 保存回答到本地存储
  Future<void> _saveLocalAnswers(List<Map<String, dynamic>> answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_answersCache, json.encode(answers));
  }

  // 创建回答
  Future<void> createAnswer(int aid, String ainfo, int uid, int alike, int questionId, {bool isSolved = false}) async {
    try {
      final newAnswer = {
        'a_id': aid,
        'ainfo': ainfo,
        'uid': uid,
        'alike': alike,
        'question_id': questionId,
        'is_solved': isSolved,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 获取现有回答
      final answers = await _getLocalAnswers();
      
      // 添加新回答
      answers.add(newAnswer);
      
      // 保存到本地
      await _saveLocalAnswers(answers);
      
      print('Answer created successfully in local storage');
    } catch (e) {
      print('Failed to create answer locally: $e');
      throw Exception('Failed to create answer: $e');
    }
  }

  // 获取特定问题的所有回答
  Future<List<ParseObject>> getAnswersByQuestionId(int questionId) async {
    try {
      // 从本地获取所有回答
      final answers = await _getLocalAnswers();
      
      // 过滤出当前问题的回答
      final questionAnswers = answers.where((a) => a['question_id'] == questionId).toList();
      
      // 转换为ParseObject
      return questionAnswers.map((data) {
        final answer = ParseObject('Answer');
        data.forEach((key, value) {
          answer.set(key, value);
        });
        return answer;
      }).toList();
    } catch (e) {
      print('获取回答失败: $e');
      return [];
    }
  }

  // 获取用户的所有回答
  Future<List<ParseObject>> getAnswersByUserId(int userId) async {
    try {
      // 从本地获取所有回答
      final answers = await _getLocalAnswers();
      
      // 过滤出用户的回答
      final userAnswers = answers.where((a) => a['uid'] == userId).toList();
      
      // 转换为ParseObject
      return userAnswers.map((data) {
        final answer = ParseObject('Answer');
        data.forEach((key, value) {
          answer.set(key, value);
        });
        return answer;
      }).toList();
    } catch (e) {
      print('获取用户回答失败: $e');
      return [];
    }
  }

  // 为回答点赞
  Future<void> likeAnswer(int answerId) async {
    try {
      // 获取所有回答
      final answers = await _getLocalAnswers();
      
      // 找到并更新目标回答
      final index = answers.indexWhere((a) => a['a_id'] == answerId);
      if (index != -1) {
        answers[index]['alike'] = (answers[index]['alike'] ?? 0) + 1;
        
        // 保存更新后的数据
        await _saveLocalAnswers(answers);
        print('Answer liked successfully');
      }
    } catch (e) {
      print('Failed to like answer: $e');
      throw Exception('Failed to like answer: $e');
    }
  }

  // 获取最新的回答数据
  Future<List<ParseObject>> fetchLatestAnswers(int questionId) async {
    // 直接返回本地数据
    return getAnswersByQuestionId(questionId);
  }
}