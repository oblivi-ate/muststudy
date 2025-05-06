import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:async';  // 导入TimeoutException类
import '../util/places.dart';
import '../widgets/search_bar.dart';
import 'resource_details.dart';
import 'problem_details.dart';
import '../theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../repositories/Question_respositories.dart';
import '../repositories/Q_tag_respositories.dart';
import '../repositories/Answer_respositories.dart';
import 'package:muststudy/routes/app_router.dart';
import '../repositories/Userinfo_respositories.dart';
import '../examples/example_upload.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  String _selectedCategory = '全部';
  String _selectedCollege = '全部';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  final QuestionRepository _questionRepository = QuestionRepository();
  final QtagRepository _qtagRepository = QtagRepository();
  List<ParseObject> _questions = [];
  List<ParseObject> _tags = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _usingLocalData = false;

  // 本地数据作为备份
  final List<Map<String, dynamic>> _localQuestions = [
    {
      'q_id': 1,
      'q_person_id': 1,
      'q_title': '如何实现高效排序算法？',
      'q_information': '我需要对大量数据进行排序，请推荐一些高效的算法及其实现方式。',
      'q_like': 10,
      'q_description': '关于排序算法的问题',
      'q_difficulty': '中等',
      'q_tags': ['算法', '数据结构'],
      'q_college': '创新工程学院',
      'q_submission_count': 5,
      'q_success_count': 3
    },
    {
      'q_id': 2,
      'q_person_id': 2,
      'q_title': '数据库索引优化策略',
      'q_information': '在处理大型数据表时，如何优化索引提高查询效率？',
      'q_like': 8,
      'q_description': '关于数据库优化的问题',
      'q_difficulty': '简单',
      'q_tags': ['数据库'],
      'q_college': '创新工程学院',
      'q_submission_count': 12,
      'q_success_count': 10
    },
    {
      'q_id': 3,
      'q_person_id': 3,
      'q_title': '系统设计—如何设计高并发系统',
      'q_information': '设计一个可以处理高并发请求的系统架构，要考虑哪些因素？',
      'q_like': 15,
      'q_description': '关于系统架构设计的问题',
      'q_difficulty': '困难',
      'q_tags': ['系统设计', '后端开发'],
      'q_college': '创新工程学院',
      'q_submission_count': 3,
      'q_success_count': 1
    }
  ];

  // 添加学院列表
  final List<String> _colleges = [
    '全部',
    '创新工程学院',
    '商学院',
    '国际学院',
  ];

  // 添加不同学院的标签映射
  final Map<String, List<String>> _collegeCategories = {
    '全部': ['全部', 'SE462', 'SE460', 'SE250', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'],
    '创新工程学院': ['全部', 'SE462', 'SE460', 'SE250', '算法', '数据结构', '系统设计', '数据库', '前端开发', '后端开发'],
    '商学院': ['全部', '会计', '金融', '市场营销', '经济学', '管理学'],
    '国际学院': ['全部', '国际贸易', '商务英语', '跨文化管理', '国际金融'],
  };

  void _showCollegeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择学院',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _colleges.length,
                  itemBuilder: (context, index) {
                    final college = _colleges[index];
                    return ListTile(
                      title: Text(college),
                      trailing: _selectedCollege == college
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCollege = college;
                          // 重置分类选择
                          _selectedCategory = '全部';
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    // 直接加载问题
    _loadQuestionsFromCache();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 从缓存加载问题
  Future<void> _loadQuestionsFromCache() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('开始加载问题数据...');
      
      // 设置超时，0.5秒后如果没有完成，直接使用本地数据
      // 增加到0.5秒以确保有足够时间加载所有题目
      bool isCompleted = false;
      
      // 启动一个定时器，如果加载时间过长则直接使用本地数据
      Timer(const Duration(milliseconds: 500), () {
        if (!isCompleted) {
          print('加载超时，直接使用本地数据');
          setState(() {
            _useLocalData();
            _isLoading = false;
          });
        }
      });
      
      // 尝试加载数据
      await _loadQuestions();
      isCompleted = true;
      
      // 如果没有数据或数据数量少于预期，强制重新初始化并加载默认数据
      if (_questions.isEmpty || _questions.length < 10) {
        print('题目数量不足 (${_questions.length}), 加载默认数据');
        await _questionRepository.initializeDefaultQuestions();
        final defaultQuestions = await _questionRepository.fetchQuestions();
        
        // 合并已有题目和默认题目
        final mergedQuestions = [..._questions];
        for (var defaultQ in defaultQuestions) {
          final defaultId = defaultQ.get<int>('q_id');
          final exists = mergedQuestions.any((q) => q.get<int>('q_id') == defaultId);
          if (!exists) {
            mergedQuestions.add(defaultQ);
          }
        }
        
        setState(() {
          _questions = mergedQuestions;
          print('合并后共有 ${_questions.length} 个题目');
        });
      }
    } catch (e) {
      print('加载问题数据失败: $e');
      _useLocalData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 使用本地数据
  Future<void> _useLocalData() async {
    try {
      print('使用本地默认数据...');
      await _questionRepository.initializeDefaultQuestions();
      final defaultQuestions = await _questionRepository.fetchQuestions();
      
      setState(() {
        _questions = defaultQuestions;
        _usingLocalData = true;
      });
    } catch (e) {
      print('加载默认数据失败: $e');
    }
  }

  // 强制创建示例数据
  Future<void> _createForceSampleData() async {
    try {
      print('开始强制创建示例数据...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 创建第一个示例问题
      await _questionRepository.createQuestionItem(
        timestamp, // 使用时间戳作为ID，避免冲突
        1, // 用户ID
        "如何实现高效的排序算法？", // 标题
        "我需要对大量数据进行排序，请推荐一些高效的算法及其实现方式。", // 内容
        0, // 初始点赞数
        "这是一个关于算法效率的问题", // 描述
        "中等", // 难度
        ["算法", "数据结构"], // 标签
        "创新工程学院" // 学院
      );
      
      // 为问题添加标签
      await _qtagRepository.createQtagItem(timestamp, ["算法", "数据结构"]);
      
      // 添加一个示例回答
      final answerRepo = AnswerRespositories();
      await answerRepo.createAnswer(
        timestamp, // 回答ID
        "对于大量数据排序，我推荐使用快速排序或归并排序算法。它们的平均时间复杂度都是O(nlogn)。在实际应用中，快速排序通常表现更好，因为它有更好的局部性。", // 回答内容
        2, // 回答者ID
        0, // 初始点赞数
        timestamp  // 问题ID
      );
      
      // 创建第二个示例问题
      await _questionRepository.createQuestionItem(
        timestamp + 1, 
        2, 
        "数据库索引优化策略", 
        "在处理大型数据表时，如何优化索引提高查询效率？", 
        0, 
        "关于数据库优化的问题", 
        "简单", 
        ["数据库"], 
        "创新工程学院"
      );
      
      await _qtagRepository.createQtagItem(timestamp + 1, ["数据库"]);
      
      print("强制创建示例数据成功");
    } catch (e) {
      print('强制创建示例数据失败: $e');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      print('开始加载问题...');
      // 1. 首先从本地加载数据
      print('从本地加载数据...');
      final localQuestions = await _questionRepository.fetchQuestions();
      print('从本地获取到${localQuestions.length}个问题');
      if (localQuestions.isNotEmpty) {
        for (var q in localQuestions) {
          print('本地题目 - ID: ${q.get<int>('q_id')}, 标题: ${q.get<String>('q_title')}');
        }
        
        // 设置为从本地加载的题目
        setState(() {
          _questions = localQuestions;
          _usingLocalData = false; // 这里设置false，因为我们是从本地存储中正常加载的
        });
      } else {
        // 如果本地没有数据，初始化默认数据
        print('本地无数据，初始化默认数据');
        await _questionRepository.initializeDefaultQuestions();
        // 重新从本地加载
        final defaultQuestions = await _questionRepository.fetchQuestions();
        setState(() {
          _questions = defaultQuestions;
          _usingLocalData = false;
        });
      }
      
      // 2. 然后尝试从Parse服务器获取，但失败时不抛出异常
      try {
        print('尝试从Parse服务器获取题目（超时设置为0.3秒）...');
        // 创建一个超时的Future
        final timeoutFuture = Future.delayed(const Duration(milliseconds: 300))
            .then((_) => throw TimeoutException('获取Parse服务器数据超时（超过0.3秒）'));
        
        // 创建Parse查询
        final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Question'))
          ..orderByDescending('createdAt')
          ..setLimit(100); // 增加一次获取的数量
        
        // 使用Future.any竞争，谁先完成就用谁的结果
        final response = await Future.any([
          queryBuilder.query(),
          timeoutFuture
        ]);
        
        if (response.success && response.results != null && response.results!.isNotEmpty) {
          print('从Parse服务器获取成功，共 ${response.results!.length} 条记录');
          
          // 如果服务器有数据，将其与本地数据合并
          final serverQuestions = response.results!.cast<ParseObject>();
          final mergedQuestions = [..._questions]; // 使用已加载的题目列表
          
          // 检查是否有新题目需要添加
          for (var serverQ in serverQuestions) {
            final serverId = serverQ.get<int>('q_id');
            final exists = mergedQuestions.any((q) => q.get<int>('q_id') == serverId);
            if (!exists) {
              mergedQuestions.add(serverQ);
            }
          }
          
          setState(() {
            _questions = mergedQuestions;
            _usingLocalData = false;
          });
        }
      } catch (serverError) {
        print('从Parse服务器获取失败: $serverError');
        // 服务器获取失败时不抛出异常，继续使用本地数据
      }
      
      // 确保题目列表不为空
      if (_questions.isEmpty) {
        print('没有获取到任何问题数据，将使用默认数据');
        await _useLocalData();
      } else {
        print('最终问题列表包含 ${_questions.length} 个问题');
      }
    } catch (e) {
      print('加载问题失败: $e');
      setState(() {
        _errorMessage = '加载数据失败: $e';
      });
      await _useLocalData();
    }
  }

  Future<void> _loadTags() async {
    try {
      // 设置超时
      final timeout = Future.delayed(const Duration(milliseconds: 300));
      
      final tags = await Future.any([
        _qtagRepository.fetchQtag(),
        timeout,
      ]);
      
      if (tags != null) {
        setState(() {
          _tags = tags;
        });
      }
    } catch (e) {
      print('Error loading tags: $e');
    }
  }

  // 使用修改过的筛选逻辑，基于学院和标签筛选问题
  Future<List<ParseObject>> _getFilteredQuestions() async {
    try {
      print('筛选问题，学院: $_selectedCollege, 标签: $_selectedCategory, 搜索: $_searchQuery');
      
      // 如果问题列表为空，先尝试从本地加载
      if (_questions.isEmpty) {
        print('问题列表为空，尝试从本地加载...');
        _questions = await _questionRepository.fetchQuestions();
        if (_questions.isEmpty) {
          print('本地也没有题目，使用默认数据');
          _useLocalData();
        } else {
          print('从本地加载了 ${_questions.length} 个题目');
        }
      }
      
      // 在内存中筛选问题，而不是调用API
      final List<ParseObject> filtered = _questions.where((q) {
        // 学院筛选
        if (_selectedCollege != '全部') {
          final qCollege = q.get<String>('q_college') ?? '';
          if (qCollege != _selectedCollege) {
            return false;
          }
        }
        
        // 标签筛选
        if (_selectedCategory != '全部') {
          // 处理选择的标签，移除可能的#前缀
          final String searchCategory = _selectedCategory.startsWith('#') ? 
              _selectedCategory.substring(1) : _selectedCategory;
          
          // 获取题目标签 - 处理不同可能的格式
          List<String> qTags = [];
          final tagsValue = q.get('q_tags');
          
          if (tagsValue is List) {
            // 直接是List类型
            qTags = tagsValue.map((t) => t.toString()).toList();
          } else if (tagsValue is String) {
            // 字符串格式，尝试分割
            qTags = tagsValue.split(',').map((tag) => tag.trim()).toList();
          }
          
          print('题目: ${q.get<String>('q_title')}, 标签: $qTags, 查找: $searchCategory');
          
          // 检查标签是否包含所选分类（不区分大小写）
          bool hasMatchingTag = false;
          for (var tag in qTags) {
            // 处理标签字符串，移除可能的#前缀
            String processedTag = tag.toString();
            if (processedTag.startsWith('#')) {
              processedTag = processedTag.substring(1);
            }
            
            // 不区分大小写比较
            if (processedTag.toLowerCase() == searchCategory.toLowerCase()) {
              hasMatchingTag = true;
              break;
            }
          }
          
          if (!hasMatchingTag) {
            return false;
          }
        }
        
        // 搜索关键字筛选
        if (_searchQuery.isNotEmpty) {
          final qTitle = q.get<String>('q_title')?.toLowerCase() ?? '';
          final qDescription = q.get<String>('q_description')?.toLowerCase() ?? '';
          final qInformation = q.get<String>('q_information')?.toLowerCase() ?? '';
          
          if (!qTitle.contains(_searchQuery.toLowerCase()) && 
              !qDescription.contains(_searchQuery.toLowerCase()) && 
              !qInformation.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      print('筛选结果: ${filtered.length}个问题');
      
      // 对结果进行排序，默认按创建时间降序
      filtered.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.now();
        final bTime = b.createdAt ?? DateTime.now();
        return bTime.compareTo(aTime); // 降序排列
      });
      
      return filtered;
    } catch (e) {
      print('筛选问题失败: $e');
      return [];
    }
  }

  // 点赞问题的方法
  Future<void> _likeQuestion(int questionId) async {
    try {
      await _questionRepository.likeQuestion(questionId);
      // 刷新问题列表
      _loadQuestions();
    } catch (e) {
      print('点赞失败: $e');
    }
  }

  // 提交问题的解答
  Future<void> _submitSolution(int questionId, bool isSuccess) async {
    try {
      // 增加提交次数
      await _questionRepository.incrementSubmissionCount(questionId);
      
      // 如果解答成功，增加成功次数
      if (isSuccess) {
        await _questionRepository.incrementSuccessCount(questionId);
      }
      
      // 刷新问题列表
      _loadQuestions();
    } catch (e) {
      print('提交解答失败: $e');
    }
  }

  // 点赞评论
  Future<void> _likeComment(int qid, int commentIndex) async {
    final userId = await UserinfoRepository().getUserId();
    final isLiked = await _questionRepository.isCommentLiked(qid, commentIndex, userId);
    
    if (!isLiked) {
      await _questionRepository.likeComment(qid, commentIndex, userId);
      setState(() {});
    }
  }

  // 切换题目完成状态
  Future<void> _toggleQuestionCompletion(int qid) async {
    final userId = await UserinfoRepository().getUserId();
    await _questionRepository.toggleQuestionCompletion(qid, userId);
    setState(() {});
  }

  // 检查题目完成状态
  Future<bool> _isQuestionCompleted(int qid) async {
    final userId = await UserinfoRepository().getUserId();
    return await _questionRepository.isQuestionCompleted(qid, userId);
  }

  // 构建评论列表
  Widget _buildComments(List<dynamic> comments, int questionId) {
    return FutureBuilder<int>(
      future: UserinfoRepository().getUserId(),
      builder: (context, userIdSnapshot) {
        if (!userIdSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final userId = userIdSnapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '评论',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder<bool>(
                  future: _questionRepository.isCommentLiked(
                    questionId,
                    index,
                    userId,
                  ),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['content'],
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '用户${comment['user_id']}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        size: 16.0,
                                        color: isLiked ? Colors.blue : Colors.grey[600],
                                      ),
                                      onPressed: isLiked ? null : () => _likeComment(questionId, index),
                                    ),
                                    Text(
                                      '${comment['likes'] ?? 0}',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFE4D4),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4D4),
        elevation: 0,
        title: Text(
          _selectedCollege,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.school, color: Colors.black87),
            onPressed: () => _showCollegeSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFFFE4D4),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                color: const Color(0xFFFFE4D4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "今天想学点什么？",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '搜索题目...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryChips(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty && !_usingLocalData
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 72, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.red[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadQuestionsFromCache,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedCategory == '全部' ? "热门题目" : "${_selectedCategory}题目",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: '刷新题目列表',
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      
                                      // 使用短超时
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        _loadQuestions().then((_) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          
                                          // 显示刷新成功提示
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('题目列表已刷新')),
                                          );
                                        }).catchError((e) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPopularProblems(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'upload_example',
            onPressed: () async {
              // 使用示例上传类上传一个示例题目
              final exampleUploader = ExampleUpload();
              await exampleUploader.uploadExampleQuestion(context);
              
              // 上传成功后刷新题目列表
              setState(() {
                _isLoading = true;
              });
              
              // 直接从本地重新加载所有题目
              try {
                print('示例题目上传完成，从本地存储加载全部题目...');
                final allQuestions = await _questionRepository.fetchQuestions();
                
                setState(() {
                  _questions = allQuestions;
                  _isLoading = false;
                  print('重新加载了 ${_questions.length} 个题目');
                });
                
                // 显示刷新成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('示例题目已上传，列表已更新')),
                );
              } catch (e) {
                print('重新加载题目失败: $e');
                setState(() {
                  _isLoading = false;
                });
              }
            },
            label: const Text('上传示例题目'),
            icon: const Icon(Icons.science),
            backgroundColor: Colors.teal,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'upload',
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.uploadQuestions).then((_) {
                // 强制刷新题目列表
                setState(() {
                  _isLoading = true;
                });
                
                // 减少延迟时间
                Future.delayed(const Duration(milliseconds: 200), () async {
                  try {
                    // 直接从本地存储重新加载所有题目
                    print('上传完成，从本地存储加载全部题目...');
                    final allQuestions = await _questionRepository.fetchQuestions();
                    
                    setState(() {
                      _questions = allQuestions;
                      _isLoading = false;
                      print('重新加载了 ${_questions.length} 个题目');
                    });
                    
                    // 显示刷新成功提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('题目上传成功，列表已更新')),
                    );
                  } catch (e) {
                    print('重新加载题目失败: $e');
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
              });
            },
            label: const Text('上传题目'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    // 获取当前选中学院的标签列表
    final categories = _collegeCategories[_selectedCollege] ?? _collegeCategories['全部']!;

    return SizedBox(
      height: 50.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : '全部';
                    print('选择标签: $_selectedCategory');
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPopularProblems() {
    return FutureBuilder<List<ParseObject>>(
      future: _getFilteredQuestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_usingLocalData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError && !_usingLocalData) {
          return Center(
            child: Text(
              '加载失败: ${snapshot.error}',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        }
        
        final filteredQuestions = snapshot.data ?? [];
        
        if (filteredQuestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 72, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "没有找到符合条件的题目",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredQuestions.length,
          itemBuilder: (context, index) {
            final question = filteredQuestions[index];
            final questionId = question.get<int>('q_id') ?? 0;
            
            // 获取标签进行显示
            List<String> qTags = [];
            final tagsValue = question.get('q_tags');
            
            if (tagsValue is List) {
              qTags = tagsValue.map((t) => t.toString()).toList();
            } else if (tagsValue is String) {
              qTags = tagsValue.split(',').map((tag) => tag.trim()).toList();
            }
            
            return FutureBuilder<bool>(
              future: _isQuestionCompleted(questionId),
              builder: (context, completedSnapshot) {
                final isCompleted = completedSnapshot.data ?? false;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          question.get<String>('q_title') ?? '无标题',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.get<String>('q_description') ?? '无描述',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // 显示标签
                            if (qTags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: qTags.map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
                                  padding: EdgeInsets.zero,
                                )).toList(),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                            color: isCompleted ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleQuestionCompletion(questionId),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProblemDetails(problem: question),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
