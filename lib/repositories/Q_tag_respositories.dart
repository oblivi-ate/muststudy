import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QtagRepository {
  // 创建标签
  Future<void> createQtagItem(int questionId, List<String> tags) async {
    try {
      print('QtagRepository: 开始创建标签，问题ID: $questionId, 标签: $tags');
      
      // 处理可能的标签格式问题，确保没有#前缀
      final List<String> processedTags = tags.map((tag) {
        // 如果标签以#开头，移除#
        return tag.startsWith('#') ? tag.substring(1) : tag;
      }).toList();
      
      // 将标签列表转换为逗号分隔的字符串
      final String tagsString = processedTags.join(',');
      print('QtagRepository: 转换后的标签字符串: $tagsString');
      
      final Qtag = ParseObject('Q_tags')
       ..set('q_id', questionId)
       ..set('q_tags', tagsString);  // 使用字符串而不是数组
      
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
    if (college == '全部') {
      return ['全部', 'SE462', 'SE460', 'SE250', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'];
    } else if (college == '创新工程学院') {
      return ['全部', 'SE462', 'SE460', 'SE250', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'];
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
      final String currentTagsString = tagObj.get<String>('q_tags') ?? '';
      final List<String> currentTags = currentTagsString.isEmpty ? [] : currentTagsString.split(',');
      
      if (!currentTags.contains(newTag)) {
        currentTags.add(newTag);
        tagObj.set('q_tags', currentTags.join(','));
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
    
    // 处理标签格式，移除可能的#前缀
    final String processedTag = tag.startsWith('#') ? tag.substring(1) : tag;
    
    // 由于标签现在是存储为逗号分隔的字符串，需要使用模糊查询
    final query = QueryBuilder<ParseObject>(ParseObject('Q_tags'))
      ..whereContains('q_tags', processedTag);  // 使用包含查询而不是数组包含查询
    final response = await query.query();
    
    if (response.success && response.results != null) {
      final List<int> questionIds = [];
      for (var result in response.results!) {
        // 验证这是否是一个精确匹配，避免子字符串匹配问题
        final String tagString = result.get<String>('q_tags') ?? '';
        final List<String> tags = tagString.split(',');
        
        bool matchFound = false;
        for (var t in tags) {
          final String processedT = t.startsWith('#') ? t.substring(1) : t;
          if (processedT.toLowerCase() == processedTag.toLowerCase()) {
            matchFound = true;
            break;
          }
        }
        
        if (matchFound) {
          final qId = result.get<int>('q_id');
          if (qId != null && qId > 0) {
            questionIds.add(qId);
          }
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
