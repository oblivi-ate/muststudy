import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../repositories/Userinfo_respositories.dart';
import '../repositories/Question_respositories.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';
import 'problem_details.dart';
import 'resource_details.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  final UserinfoRepository _userinfoRepository = UserinfoRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  late TabController _tabController;
  int _userId = 1;
  bool _isLoading = true;
  
  // 收藏的资源和题目
  List<Resource> _bookmarkedResources = [];
  List<ParseObject> _bookmarkedQuestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加载用户收藏
  Future<void> _loadUserBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取当前用户ID
      _userId = await _userinfoRepository.getUserId();
      
      // 并行加载收藏的资源和题目
      await Future.wait([
        _loadBookmarkedResources(),
        _loadBookmarkedQuestions(),
      ]);
      
      // 在加载完成后同步喜马拉雅收藏家成就进度，确保成就数据与实际收藏数量同步
      await _userinfoRepository.syncHimalayaCollectorAchievement(_userId);
    } catch (e) {
      print('加载收藏失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 加载收藏的资源
  Future<void> _loadBookmarkedResources() async {
    try {
      // 获取收藏的资源ID列表
      final bookmarkedResourceIds = await _userinfoRepository.getUserResourceBookmarks(_userId);
      
      // 创建资源列表
      final resources = bookmarkedResourceIds.map((id) {
        // 创建资源对象，提供所有必需参数
        return Resource(
          id: id,
          title: '资源 $id',
          description: '收藏的学习资源',
          category: '未分类',
          type: '未知类型',
          imageUrl: 'https://picsum.photos/200/300?random=${id.hashCode % 100}',
          author: '未知作者',
          college: '未知学院',
          url: '',
        );
      }).toList();
      
      // 在实际应用中，这里应该从数据库获取完整的资源信息
      // TODO: 从数据库加载完整资源信息
      
      setState(() {
        _bookmarkedResources = resources;
      });
    } catch (e) {
      print('加载收藏的资源失败: $e');
    }
  }

  // 加载收藏的题目
  Future<void> _loadBookmarkedQuestions() async {
    try {
      // 获取收藏的题目ID列表
      final bookmarkedQuestionIds = await _userinfoRepository.getUserBookmarks(_userId);
      
      // 获取所有题目
      final allQuestions = await _questionRepository.fetchQuestions();
      
      // 过滤出收藏的题目
      final bookmarkedQuestions = allQuestions.where((question) {
        final questionId = question.get<int>('q_id');
        return questionId != null && bookmarkedQuestionIds.contains(questionId);
      }).toList();
      
      setState(() {
        _bookmarkedQuestions = bookmarkedQuestions;
      });
    } catch (e) {
      print('加载收藏的题目失败: $e');
    }
  }

  // 取消收藏资源
  Future<void> _unbookmarkResource(String resourceId) async {
    try {
      final success = await _userinfoRepository.unbookmarkResource(_userId, resourceId);
      if (success) {
        setState(() {
          _bookmarkedResources.removeWhere((resource) => resource.id == resourceId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已从收藏中移除')),
        );
      }
    } catch (e) {
      print('取消收藏资源失败: $e');
    }
  }

  // 取消收藏题目
  Future<void> _unbookmarkQuestion(int questionId) async {
    try {
      final success = await _userinfoRepository.unbookmarkQuestion(_userId, questionId);
      if (success) {
        setState(() {
          _bookmarkedQuestions.removeWhere(
            (question) => question.get<int>('q_id') == questionId
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已从收藏中移除')),
        );
      }
    } catch (e) {
      print('取消收藏题目失败: $e');
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
          '我的收藏',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: '学习资源'),
            Tab(text: '学习论坛'),
          ],
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildResourcesTab(),
              _buildQuestionsTab(),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserBookmarks,
        tooltip: '刷新',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // 构建资源标签页
  Widget _buildResourcesTab() {
    if (_bookmarkedResources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "暂无收藏的学习资源",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "在学习资源页面收藏你喜欢的内容吧",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarkedResources.length,
      itemBuilder: (context, index) {
        final resource = _bookmarkedResources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              resource.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              resource.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.amber),
              onPressed: () => _unbookmarkResource(resource.id),
              tooltip: '取消收藏',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourceDetails(resource: resource),
                ),
              ).then((_) => _loadBookmarkedResources());
            },
          ),
        );
      },
    );
  }

  // 构建问题标签页
  Widget _buildQuestionsTab() {
    if (_bookmarkedQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "暂无收藏的论坛题目",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "在学习论坛页面收藏你感兴趣的题目吧",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarkedQuestions.length,
      itemBuilder: (context, index) {
        final question = _bookmarkedQuestions[index];
        final questionId = question.get<int>('q_id') ?? 0;
        final title = question.get<String>('q_title') ?? '未知标题';
        final description = question.get<String>('q_description') ?? '无描述';
        
        // 获取标签进行显示
        List<String> qTags = [];
        final tagsValue = question.get('q_tags');
        
        if (tagsValue is List) {
          qTags = tagsValue.map((t) => t.toString()).toList();
        } else if (tagsValue is String) {
          qTags = tagsValue.split(',').map((tag) => tag.trim()).toList();
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
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
              icon: const Icon(Icons.bookmark, color: Colors.amber),
              onPressed: () => _unbookmarkQuestion(questionId),
              tooltip: '取消收藏',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProblemDetails(problem: question),
                ),
              ).then((_) => _loadBookmarkedQuestions());
            },
          ),
        );
      },
    );
  }
} 