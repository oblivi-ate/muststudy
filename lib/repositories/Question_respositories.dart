import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QuestionRepository {
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
    final query = QueryBuilder<ParseObject>(ParseObject('Question'))
      ..whereEqualTo('q_id', qid);
    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    }
    return null;
  }

  // 获取所有问题，可指定按创建时间或点赞数排序
  Future<List<ParseObject>> fetchQuestions({String orderBy = 'createdAt'}) async {
    print('Repository: 开始获取问题列表，排序方式: $orderBy');
    final query = QueryBuilder<ParseObject>(ParseObject('Question'));
    
    if (orderBy == 'createdAt') {
      query.orderByDescending('createdAt');
    } else if (orderBy == 'likes') {
      query.orderByDescending('q_like');
    }
    
    final response = await query.query();
    if (response.success && response.results != null) {
      print('Repository: 成功获取${response.results!.length}个问题');
      return response.results as List<ParseObject>;
    }
    print('Repository: 获取问题失败，错误: ${response.error?.message}');
    throw Exception('Failed to fetch questions');
  }

  // 根据学院和标签筛选问题
  Future<List<ParseObject>> filterQuestions({
    String college = '全部',
    String tag = '全部',
    String searchQuery = '',
  }) async {
    print('Repository: 过滤问题，学院: $college, 标签: $tag, 搜索: $searchQuery');
    final query = QueryBuilder<ParseObject>(ParseObject('Question'));
    
    if (college != '全部') {
      print('Repository: 按学院过滤: $college');
      query.whereEqualTo('q_college', college);
    }
    
    if (tag != '全部') {
      print('Repository: 按标签过滤: $tag');
      query.whereContainedIn('q_tags', [tag]); // 使用whereContainedIn替代whereArrayContains
    }
    
    if (searchQuery.isNotEmpty) {
      print('Repository: 按搜索词过滤: $searchQuery');
      query.whereContains('q_title', searchQuery);
      // 由于Parse Server不支持OR查询，如果要搜索描述，需要进行另一次查询然后在客户端合并结果
    }
    
    final response = await query.query();
    if (response.success && response.results != null) {
      print('Repository: 过滤结果: ${response.results!.length}个问题');
      return response.results as List<ParseObject>;
    }
    print('Repository: 过滤问题失败，错误: ${response.error?.message}');
    throw Exception('Failed to filter questions');
  }

  // 为问题添加点赞
  Future<void> likeQuestion(int qid) async {
    final question = await getQuestionById(qid);
    if (question != null) {
      final currentLikes = question.get<int>('q_like') ?? 0;
      question.set('q_like', currentLikes + 1);
      await question.save();
    }
  }

  // 记录问题提交次数
  Future<void> incrementSubmissionCount(int qid) async {
    final question = await getQuestionById(qid);
    if (question != null) {
      final submissionCount = question.get<int>('q_submission_count') ?? 0;
      question.set('q_submission_count', submissionCount + 1);
      await question.save();
    }
  }

  // 记录问题成功解答次数
  Future<void> incrementSuccessCount(int qid) async {
    final question = await getQuestionById(qid);
    if (question != null) {
      final successCount = question.get<int>('q_success_count') ?? 0;
      question.set('q_success_count', successCount + 1);
      await question.save();
    }
  }

  // 获取热门问题（浏览量或提交次数较多的问题）
  Future<List<ParseObject>> getHotQuestions(int limit) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Question'))
      ..orderByDescending('q_submission_count')
      ..setLimit(limit);
    
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }

  // 获取某学院的推荐问题
  Future<List<ParseObject>> getRecommendedQuestions(String college, int limit) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Question'));
    
    if (college != '全部') {
      query.whereEqualTo('q_college', college);
    }
    
    query.orderByDescending('q_like');
    query.setLimit(limit);
    
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }
}