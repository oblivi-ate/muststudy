import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
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
      await _loadQuestions();
      
      // 如果没有数据，使用本地数据
      if (_questions.isEmpty) {
        _useLocalData();
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
  void _useLocalData() {
    print('使用本地数据作为备份');
    setState(() {
      _usingLocalData = true;
      _questions = _localQuestions.map((data) {
        final obj = ParseObject('Question');
        data.forEach((key, value) {
          obj.set(key, value);
        });
        return obj;
      }).toList();
    });
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
      print('开始加载问题数据...');
      // 设置超时
      final timeout = Future.delayed(const Duration(milliseconds: 300));
      
      final questions = await Future.any([
        _questionRepository.fetchQuestions(),
        timeout,
      ]);
      
      print('成功获取到${questions.length}个问题');
      if (questions.isNotEmpty) {
        for (var q in questions) {
          print('问题ID: ${q.get<int>('q_id')}, 标题: ${q.get<String>('q_title')}');
        }
      } else {
        print('没有获取到任何问题数据');
      }
      setState(() {
        _questions = questions;
        _usingLocalData = false;
      });
    } catch (e) {
      print('加载问题失败: $e');
      setState(() {
        _errorMessage = '加载数据失败: $e';
      });
      throw e; // 重新抛出异常，让上层函数处理
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
      
      // 使用新的filterQuestions方法
      final filtered = await _questionRepository.filterQuestions(
        college: _selectedCollege == '全部' ? null : _selectedCollege,
        tag: _selectedCategory == '全部' ? null : _selectedCategory,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery
      );
      
      print('筛选结果: ${filtered.length}个问题');
      print('标签: ${filtered.map((q) => q.get<List>('q_tags')).toList()}');
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'upload',
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.uploadQuestions).then((_) {
            _loadQuestions();
          });
        },
        label: const Text('上传题目'),
        icon: const Icon(Icons.add),
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
                        subtitle: Text(
                          question.get<String>('q_description') ?? '无描述',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
