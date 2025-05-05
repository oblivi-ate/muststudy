import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionRepository {
  static const String _cacheKey = 'cached_questions';
  static const Duration _cacheDuration = Duration(days: 7); // 延长缓存有效期到7天
  static const String _questionsCache = 'local_questions';
  
  // 标记连接状态
  static bool _isConnectionFailed = false;

  Future<void> createQuestionItem(int qid, int userId, String title, String content,
      int likeCount, String description, String difficulty, List<String> tags, String college) async {
    try {
      print('QuestionRepository: 开始创建问题，ID: $qid, 用户ID: $userId');
      final question = ParseObject('Question')
        ..set('q_id', qid)
        ..set('q_person_id', userId)
        ..set('q_title', title)
        ..set('q_information', content)
        ..set('q_like', likeCount)
        ..set('q_description', description)
        ..set('q_difficulty', difficulty)
        ..set('q_tags', tags)
        ..set('q_college', college)
        ..set('q_submission_count', 0)
        ..set('q_success_count', 0);
      
      print('QuestionRepository: 准备保存问题对象');
      final response = await question.save();
      
      if (response.success) {
        print('QuestionRepository: 问题创建成功: ${response.results?.first.objectId}');
      } else {
        print('QuestionRepository: 问题创建失败: ${response.error?.message}');
        throw Exception('Failed to create question: ${response.error?.message}');
      }
    } catch (e) {
      print('QuestionRepository: 创建问题时发生异常: $e');
      throw Exception('创建问题异常: $e');
    }
  }

  // 通过ID获取单个问题
  Future<ParseObject?> getQuestionById(int qid) async {
    try {
      // 先尝试从缓存获取
      final cachedQuestions = await _getCachedQuestions();
      if (cachedQuestions != null) {
        final question = cachedQuestions.firstWhere(
          (q) => q.get<int>('q_id') == qid,
          orElse: () => ParseObject('Question'),
        );
        
        if (question.objectId != null) {
          print('从缓存获取问题详情，ID: $qid');
          return question;
        }
      }
      
      // 如果缓存中没有，并且之前连接失败，则返回null
      if (_isConnectionFailed) {
        return null;
      }
      
      // 尝试从网络获取
      final query = QueryBuilder<ParseObject>(ParseObject('Question'))
        ..whereEqualTo('q_id', qid);
      final response = await query.query();
      if (response.success && response.results != null && response.results!.isNotEmpty) {
        return response.results!.first as ParseObject;
      }
    } catch (e) {
      print('获取问题详情失败: $e');
      _isConnectionFailed = true;
    }
    return null;
  }

  // 获取所有题目
  Future<List<ParseObject>> fetchQuestions({String orderBy = 'createdAt'}) async {
    try {
      // 先尝试从本地获取数据
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_questionsCache);
      
      if (data == null) {
        // 如果没有数据，先初始化
        await initializeDefaultQuestions();
        // 重新获取数据
        final newData = prefs.getString(_questionsCache);
        if (newData == null) {
          return [];
        }
        final questions = List<Map<String, dynamic>>.from(json.decode(newData));
        return _convertToParseObjects(questions, orderBy);
      }
      
      final questions = List<Map<String, dynamic>>.from(json.decode(data));
      return _convertToParseObjects(questions, orderBy);
    } catch (e) {
      print('获取题目失败: $e');
      return [];
    }
  }

  // 将Map转换为ParseObject并排序
  List<ParseObject> _convertToParseObjects(List<Map<String, dynamic>> questions, String orderBy) {
    final result = questions.map((q) {
      final question = ParseObject('Question');
      q.forEach((key, value) {
        if (key == 'created_at') {
          question.set(key, DateTime.now().toIso8601String());
        } else {
          question.set(key, value);
        }
      });
      return question;
    }).toList();

    // 根据orderBy参数排序
    if (orderBy == 'createdAt') {
      result.sort((a, b) {
        final aDate = DateTime.parse(a.get<String>('created_at') ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b.get<String>('created_at') ?? DateTime.now().toIso8601String());
        return bDate.compareTo(aDate);
      });
    } else if (orderBy == 'likes') {
      result.sort((a, b) {
        final aLikes = a.get<int>('q_like') ?? 0;
        final bLikes = b.get<int>('q_like') ?? 0;
        return bLikes.compareTo(aLikes);
      });
    }

    return result;
  }

  // 根据条件筛选问题
  Future<List<ParseObject>> filterQuestions({
    String? college,
    String? tag,
    String? searchQuery,
  }) async {
    try {
      final allQuestions = await fetchQuestions();
      print('过滤前总问题数: ${allQuestions.length}');
      print('过滤条件 - 学院: $college, 标签: $tag, 搜索: $searchQuery');
      
      final filteredQuestions = allQuestions.where((q) {
        final qCollege = q.get<String>('q_college') ?? '';
        final qTags = q.get<List>('q_tags') ?? [];
        final qTitle = q.get<String>('q_title') ?? '';
        final qDescription = q.get<String>('q_description') ?? '';
        final qInformation = q.get<String>('q_information') ?? '';
        
        print('问题: ${q.get<String>('q_title')}');
        print('问题标签: $qTags');
        
        // 检查学院筛选
        if (college != null && qCollege != college) {
          print('学院不匹配: $qCollege != $college');
          return false;
        }
        
        // 检查标签筛选
        if (tag != null && !(qTags is List && qTags.contains(tag))) {
          print('标签不匹配: $qTags 不包含 $tag');
          return false;
        }
        
        // 检查搜索关键词
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          final matches = qTitle.toLowerCase().contains(searchLower) ||
              qDescription.toLowerCase().contains(searchLower) ||
              qInformation.toLowerCase().contains(searchLower) ||
              qCollege.toLowerCase().contains(searchLower);
          if (!matches) {
            print('搜索不匹配: $searchQuery');
            return false;
          }
        }
        
        print('问题匹配所有条件');
        return true;
      }).toList();

      print('过滤后问题数: ${filteredQuestions.length}');
      return filteredQuestions;
    } catch (e) {
      print('筛选问题失败: $e');
      return [];
    }
  }

  // 保存问题到缓存
  Future<void> _cacheQuestions(List<ParseObject> questions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 序列化问题数据
      final cachedData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'questions': questions.map((question) => question.toJson()).toList(),
      };
      
      await prefs.setString(_cacheKey, jsonEncode(cachedData));
      print('问题数据已缓存，共 ${questions.length} 条记录');
    } catch (e) {
      print('缓存问题数据失败: $e');
    }
  }
  
  // 从缓存获取问题
  Future<List<ParseObject>?> _getCachedQuestions({bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);
      
      if (cachedString == null) {
        return null;
      }
      
      final cachedData = jsonDecode(cachedString);
      final timestamp = cachedData['timestamp'] as int;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // 检查缓存是否过期
      if (!ignoreExpiry && DateTime.now().difference(cachedTime) > _cacheDuration) {
        print('问题缓存已过期');
        return null;
      }
      
      // 反序列化问题数据
      final questionsJson = cachedData['questions'] as List;
      final questions = questionsJson.map((json) {
        final question = ParseObject('Question');
        question.fromJson(json);
        return question;
      }).toList();
      
      print('从缓存获取了 ${questions.length} 条问题记录');
      return questions;
    } catch (e) {
      print('获取缓存问题数据失败: $e');
      return null;
    }
  }

  // 为问题添加点赞
  Future<void> likeQuestion(int qid) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final currentLikes = question.get<int>('q_like') ?? 0;
        question.set('q_like', currentLikes + 1);
        await question.save();
      }
    } catch (e) {
      print('点赞失败: $e');
    }
  }

  // 记录问题提交次数
  Future<void> incrementSubmissionCount(int qid) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final submissionCount = question.get<int>('q_submission_count') ?? 0;
        question.set('q_submission_count', submissionCount + 1);
        await question.save();
      }
    } catch (e) {
      print('增加提交计数失败: $e');
    }
  }

  // 记录问题成功解答次数
  Future<void> incrementSuccessCount(int qid) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final successCount = question.get<int>('q_success_count') ?? 0;
        question.set('q_success_count', successCount + 1);
        await question.save();
      }
    } catch (e) {
      print('增加成功计数失败: $e');
    }
  }

  // 获取热门问题（浏览量或提交次数较多的问题）
  Future<List<ParseObject>> getHotQuestions(int limit) async {
    try {
      final allQuestions = await fetchQuestions();
      // 在本地对数据进行排序
      allQuestions.sort((a, b) {
        final aCount = a.get<int>('q_submission_count') ?? 0;
        final bCount = b.get<int>('q_submission_count') ?? 0;
        return bCount.compareTo(aCount);
      });
      
      // 返回前limit个
      return allQuestions.take(limit).toList();
    } catch (e) {
      print('获取热门问题失败: $e');
      return [];
    }
  }

  // 获取某学院的推荐问题
  Future<List<ParseObject>> getRecommendedQuestions(String college, int limit) async {
    try {
      final allQuestions = await fetchQuestions();
      // 在本地筛选和排序
      var filtered = allQuestions;
      
      if (college != '全部') {
        filtered = allQuestions.where((q) => 
          q.get<String>('q_college') == college
        ).toList();
      }
      
      // 按点赞数排序
      filtered.sort((a, b) {
        final aLikes = a.get<int>('q_like') ?? 0;
        final bLikes = b.get<int>('q_like') ?? 0;
        return bLikes.compareTo(aLikes);
      });
      
      // 返回前limit个
      return filtered.take(limit).toList();
    } catch (e) {
      print('获取推荐问题失败: $e');
      return [];
    }
  }

  // 初始化默认题目数据
  Future<void> initializeDefaultQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 清除旧数据
      await prefs.remove(_questionsCache);
      
      final defaultQuestions = [
        // SE462 题目
        {
          'q_id': 1,
          'q_title': 'SE462：设计模式在实际项目中的应用',
          'q_description': '在一个电商系统中，如何合理使用设计模式来提高代码的可维护性？',
          'q_information': '''
设计要点：
1. 工厂模式和策略模式在支付系统中的应用
2. 观察者模式在订单状态更新中的使用
3. 装饰器模式在商品展示中的实现
4. 单例模式在配置管理中的应用
''',
          'q_like': 0,
          'q_tags': ['SE462', '设计模式'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 1,
              'content': '我在订单系统中使用了状态模式，很好地解决了订单状态流转的问题。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'q_id': 11,
          'q_title': 'SE462：领域驱动设计实践',
          'q_description': '如何使用DDD方法设计一个在线教育平台的核心域？',
          'q_information': '''
设计重点：
1. 限界上下文的划分
2. 聚合根的识别
3. 领域事件的设计
4. 防腐层的实现
''',
          'q_like': 0,
          'q_tags': ['SE462', '架构设计'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 2,
              'content': '通过事件风暴识别了核心业务流程，很好地梳理了业务边界。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // SE460 题目
        {
          'q_id': 12,
          'q_title': 'SE460：单元测试最佳实践',
          'q_description': '如何编写高质量的单元测试，提高代码的可测试性？',
          'q_information': '''
关键点：
1. 测试用例设计
2. 依赖注入和mock
3. 测试覆盖率要求
4. 边界条件测试
''',
          'q_like': 0,
          'q_tags': ['SE460', '测试'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 3,
              'content': '使用了Mockito框架模拟外部依赖，测试覆盖率达到了90%以上。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'q_id': 13,
          'q_title': 'SE460：集成测试策略',
          'q_description': '设计一个微服务架构系统的集成测试方案。',
          'q_information': '''
测试要点：
1. 服务间通信测试
2. 数据一致性验证
3. 性能测试指标
4. 故障注入测试
''',
          'q_like': 0,
          'q_tags': ['SE460', '测试'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 4,
              'content': '实现了基于Docker的集成测试环境，大大提高了测试效率。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // SE250 题目
        {
          'q_id': 14,
          'q_title': 'SE250：高性能数据库设计',
          'q_description': '设计一个支持亿级数据量的商品搜索系统。',
          'q_information': '''
设计要点：
1. 分库分表策略
2. 索引优化方案
3. 缓存架构设计
4. 读写分离实现
''',
          'q_like': 0,
          'q_tags': ['SE250', '数据库'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 5,
              'content': '采用了ES+MySQL的架构，搜索性能提升了10倍。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'q_id': 15,
          'q_title': 'SE250：数据仓库设计',
          'q_description': '设计一个电商平台的数据仓库，支持多维度数据分析。',
          'q_information': '''
设计重点：
1. 维度建模
2. ETL流程设计
3. 数据质量控制
4. 查询性能优化
''',
          'q_like': 0,
          'q_tags': ['SE250', '数据库'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 6,
              'content': '使用星型模型设计数据仓库，支持灵活的多维分析。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 算法题目
        {
          'q_id': 1,
          'q_title': '算法优化：高效的排序算法实现',
          'q_description': '请实现一个高效的排序算法，并分析其时间复杂度和空间复杂度。要求能处理大规模数据集。',
          'q_information': '''
排序算法是计算机科学中的基础问题，需要考虑以下几个方面：
1. 算法选择：快速排序、归并排序、堆排序等
2. 性能优化：分区策略、内存使用、并行处理
3. 特殊情况处理：重复元素、接近有序、极端数据
''',
          'q_like': 0,
          'q_tags': ['算法'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 1,
              'content': '我使用了快速排序算法，通过三路划分优化了重复元素的处理。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 数据结构题目
        {
          'q_id': 2,
          'q_title': '数据结构：实现一个高效的LRU缓存',
          'q_description': '设计并实现一个LRU（最近最少使用）缓存，要求支持O(1)的get和put操作。',
          'q_information': '''
LRU缓存实现要点：
1. 使用双向链表和哈希表
2. get和put操作都需要O(1)时间复杂度
3. 需要维护访问顺序和容量限制
''',
          'q_like': 0,
          'q_tags': ['数据结构'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 2,
              'content': '使用HashMap+双向链表实现，能够在O(1)时间内完成所有操作。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 系统设计题目
        {
          'q_id': 3,
          'q_title': '系统设计：分布式消息队列',
          'q_description': '设计一个可靠的分布式消息队列系统，要求支持高可用和水平扩展。',
          'q_information': '''
关键设计点：
1. 消息持久化和复制
2. 分区和负载均衡
3. 故障检测和恢复
4. 消息顺序保证
''',
          'q_like': 0,
          'q_tags': ['系统设计'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 3,
              'content': '参考了Kafka的设计，实现了基于分区的消息存储和复制机制。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 数据库题目
        {
          'q_id': 4,
          'q_title': '数据库：索引优化与查询性能',
          'q_description': '针对一个大型电商系统的商品查询功能，设计合适的索引策略。',
          'q_information': '''
需要考虑：
1. 索引类型选择
2. 复合索引设计
3. 查询优化
4. 性能监控
''',
          'q_like': 0,
          'q_tags': ['数据库'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 4,
              'content': '使用了复合索引并结合查询模式，将查询性能提升了3倍。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 前端开发题目
        {
          'q_id': 5,
          'q_title': '前端：React性能优化',
          'q_description': '优化一个大型React应用的性能，包括首屏加载和运行时性能。',
          'q_information': '''
优化方向：
1. 代码分割和懒加载
2. 虚拟列表实现
3. 状态管理优化
4. 渲染性能优化
''',
          'q_like': 0,
          'q_tags': ['前端开发'],
          'q_college': '创新工程学院',
          'q_difficulty': '中等',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 5,
              'content': '通过代码分割和React.memo优化，首屏加载时间减少了40%。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        // 后端开发题目
        {
          'q_id': 6,
          'q_title': '后端：微服务架构设计',
          'q_description': '设计一个微服务架构的电商系统，解决服务拆分和通信问题。',
          'q_information': '''
设计重点：
1. 服务边界划分
2. 通信方式选择
3. 数据一致性
4. 服务治理
''',
          'q_like': 0,
          'q_tags': ['后端开发'],
          'q_college': '创新工程学院',
          'q_difficulty': '困难',
          'q_submission_count': 0,
          'q_success_count': 0,
          'completed_by': [],
          'q_comments': [
            {
              'user_id': 6,
              'content': '采用DDD方法进行服务拆分，使用事件驱动实现服务间通信。',
              'likes': 0,
              'liked_by': [],
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
          'created_at': DateTime.now().toIso8601String(),
        }
      ];
      
      await prefs.setString(_questionsCache, json.encode(defaultQuestions));
      print('Default questions initialized');
    } catch (e) {
      print('初始化默认题目数据失败: $e');
    }
  }

  // 点赞评论
  Future<void> likeComment(int qid, int commentIndex, int userId) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final comments = question.get<List>('q_comments') ?? [];
        if (commentIndex < comments.length) {
          final comment = comments[commentIndex];
          final likedBy = comment['liked_by'] ?? [];
          
          // 检查用户是否已经点赞
          if (!likedBy.contains(userId)) {
            comment['likes'] = (comment['likes'] ?? 0) + 1;
            likedBy.add(userId);
            comment['liked_by'] = likedBy;
            question.set('q_comments', comments);
            await question.save();
          }
        }
      }
    } catch (e) {
      print('点赞评论失败: $e');
    }
  }

  // 检查评论是否已被点赞
  Future<bool> isCommentLiked(int qid, int commentIndex, int userId) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final comments = question.get<List>('q_comments') ?? [];
        if (commentIndex < comments.length) {
          final comment = comments[commentIndex];
          final likedBy = comment['liked_by'] ?? [];
          return likedBy.contains(userId);
        }
      }
      return false;
    } catch (e) {
      print('检查评论点赞状态失败: $e');
      return false;
    }
  }

  // 标记题目完成状态
  Future<void> toggleQuestionCompletion(int qid, int userId) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final completedBy = question.get<List>('completed_by') ?? [];
        final index = completedBy.indexOf(userId);
        
        if (index == -1) {
          // 添加完成状态
          completedBy.add(userId);
          await incrementSuccessCount(qid);
        } else {
          // 取消完成状态
          completedBy.removeAt(index);
          final successCount = question.get<int>('q_success_count') ?? 0;
          if (successCount > 0) {
            question.set('q_success_count', successCount - 1);
          }
        }
        
        question.set('completed_by', completedBy);
        await question.save();
      }
    } catch (e) {
      print('更新题目完成状态失败: $e');
    }
  }

  // 检查题目是否已完成
  Future<bool> isQuestionCompleted(int qid, int userId) async {
    try {
      final question = await getQuestionById(qid);
      if (question != null) {
        final completedBy = question.get<List>('completed_by') ?? [];
        return completedBy.contains(userId);
      }
      return false;
    } catch (e) {
      print('检查题目完成状态失败: $e');
      return false;
    }
  }
}