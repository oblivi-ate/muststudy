import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QtagRepository {
  // 创建标签
  Future<void> createQtagItem(int questionId, List<String> tags) async {
    try {
      print('QtagRepository: 开始创建标签，问题ID: $questionId, 标签: $tags');
      final Qtag = ParseObject('Q_tags')
       ..set('q_id', questionId)
       ..set('q_tags', tags);
      
      print('QtagRepository: 准备保存标签对象');
      final response = await Qtag.save();
      
      if (response.success) {
        print('QtagRepository: 标签创建成功: ${response.results?.first.objectId}');
      } else {
        print('QtagRepository: 标签创建失败: ${response.error?.message}');
        throw Exception('Failed to create question tags: ${response.error?.message}');
      }
    } catch (e) {
      print('QtagRepository: 创建标签时发生异常: $e');
      throw Exception('创建标签异常: $e');
    }
  }
  
  // 获取所有标签
  Future<List<ParseObject>?> fetchQtag() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Q_tags'));
    final response = await query.query();
    if (response.success && response.results!= null) {
      return response.results as List<ParseObject>;
    } else {
      return null;
    }
  }
  
  // 获取特定学院的标签
  Future<List<String>> getTagsByCollege(String college) async {
    // 这里假设有一个College_Tags表存储不同学院的标签
    // 如果没有这样的表，可以修改此方法直接返回预定义的标签列表
    if (college == '全部') {
      return ['全部', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'];
    } else if (college == '创新工程学院') {
      return ['全部', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'];
    } else if (college == '商学院') {
      return ['全部', '会计', '金融', '市场营销', '经济学', '管理学'];
    } else if (college == '国际学院') {
      return ['全部', '国际贸易', '商务英语', '跨文化管理', '国际金融'];
    } else {
      return ['全部'];
    }
  }
  
  // 为问题添加新标签
  Future<void> addTagToQuestion(int questionId, String newTag) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Q_tags'))
      ..whereEqualTo('q_id', questionId);
    final response = await query.query();
    
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      final tagObj = response.results!.first as ParseObject;
      final currentTags = tagObj.get<List>('q_tags') ?? [];
      
      if (!currentTags.contains(newTag)) {
        currentTags.add(newTag);
        tagObj.set('q_tags', currentTags);
        await tagObj.save();
      }
    } else {
      // 如果不存在，创建新记录
      await createQtagItem(questionId, [newTag]);
    }
  }
  
  // 获取某个标签下的所有问题ID
  Future<List<int>> getQuestionIdsByTag(String tag) async {
    if (tag == '全部') {
      // 如果是"全部"标签，可以返回所有问题的ID
      // 这需要查询Question表
      final questionQuery = QueryBuilder<ParseObject>(ParseObject('Question'));
      final response = await questionQuery.query();
      
      if (response.success && response.results != null) {
        final List<int> questionIds = [];
        for (var result in response.results!) {
          final qId = result.get<int>('q_id');
          if (qId != null && qId > 0) {
            questionIds.add(qId);
          }
        }
        return questionIds;
      }
      return [];
    }
    
    final query = QueryBuilder<ParseObject>(ParseObject('Q_tags'))
      ..whereContainedIn('q_tags', [tag]);
    final response = await query.query();
    
    if (response.success && response.results != null) {
      final List<int> questionIds = [];
      for (var result in response.results!) {
        final qId = result.get<int>('q_id');
        if (qId != null && qId > 0) {
          questionIds.add(qId);
        }
      }
      return questionIds;
    }
    return [];
  }
  
  // 获取热门标签（使用频率最高的标签）
  Future<List<String>> getHotTags(int limit) async {
    // 这个实现可能需要服务器端的聚合查询支持
    // 这里提供一个简化版，仅返回几个预设的热门标签
    return ['算法', '数据结构', '系统设计', '数据库'];
  }
}
