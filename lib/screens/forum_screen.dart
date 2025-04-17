import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../util/places.dart';
import '../widgets/search_bar.dart';
import 'resource_details.dart';
import 'problem_details.dart';
import '../theme/app_theme.dart';
import '../repositories/Question_respositories.dart';
import '../repositories/Q_tag_respositories.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> categories = ["算法", "数据结构", "系统设计", "数据库", "前端开发", "后端开发"];
  
  final QuestionRepository _questionRepository = QuestionRepository();
  final QtagRepository _qtagRepository = QtagRepository();
  List<ParseObject> _questions = [];
  List<ParseObject> _tags = [];

  // 根据选中的分类筛选问题
  List<ParseObject> getFilteredQuestions() {
    if (_selectedCategoryIndex == 0) return _questions;
    final category = categories[_selectedCategoryIndex];
    return _questions.where((question) {
      final tags = question.get<List>('q_tags');
      return tags != null && tags.contains(category);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadTags();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _questionRepository.fetchQuestions();
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _qtagRepository.fetchQtag();
      if (tags != null) {
        setState(() {
          _tags = tags;
        });
      }
    } catch (e) {
      print('Error loading tags: $e');
    }
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
        title: const Text(
          '学习论坛',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
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
                    const CustomSearchBar(),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _selectedCategoryIndex == 0 ? "热门题目" : "${categories[_selectedCategoryIndex]}题目",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
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
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularProblems() {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final title = question.get<String>('q_title') ?? '无标题';
        final description = question.get<String>('q_description') ?? '无描述';
        final likeCount = question.get<int>('q_like') ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProblemDetails(problem: question),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: question.get<String>('q_difficulty') == "简单"
                              ? Colors.green[50]
                              : question.get<String>('q_difficulty') == "中等"
                                  ? Colors.orange[50]
                                  : Colors.red[50],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          question.get<String>('q_difficulty') ?? '未知',
                          style: TextStyle(
                            color: question.get<String>('q_difficulty') == "简单"
                                ? Colors.green[700]
                                : question.get<String>('q_difficulty') == "中等"
                                    ? Colors.orange[700]
                                    : Colors.red[700],
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 16.0, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Text(
                        "通过率: ${((question.get<int>('q_success_count') ?? 0) / (question.get<int>('q_submission_count') ?? 1) * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Icon(Icons.people_outline, size: 16.0, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Text(
                        "${question.get<int>('q_submission_count') ?? 0}人提交",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
