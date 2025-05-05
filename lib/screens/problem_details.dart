import 'package:flutter/material.dart';
import '../util/places.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/Question_respositories.dart';
import '../repositories/Q_tag_respositories.dart';
import '../repositories/Userinfo_respositories.dart';
import '../repositories/Answer_respositories.dart';
import 'dart:convert';

class ProblemDetails extends StatefulWidget {
  final ParseObject problem;

  const ProblemDetails({
    Key? key,
    required this.problem,
  }) : super(key: key);

  @override
  _ProblemDetailsState createState() => _ProblemDetailsState();
}

class _ProblemDetailsState extends State<ProblemDetails> {
  final TextEditingController _messageController = TextEditingController();
  final QuestionRepository _questionRepository = QuestionRepository();
  final QtagRepository _qtagRepository = QtagRepository();
  final UserinfoRepository _userinfoRepository = UserinfoRepository();
  final AnswerRespositories _answerRepository = AnswerRespositories();
  
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isSolved = false;
  bool _isSubmitting = false;
  bool _isBookmarking = false;
  int _userId = 0;
  String _username = '';
  List<ParseObject> _answers = [];
  bool _isLoadingAnswers = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUser();  // 先加载用户信息
    if (mounted) {
      await _checkIfSolved();  // 然后检查题目状态
      await _loadQuestionDetails();  // 最后加载评论
    }
  }
  
  // 加载当前用户信息
  Future<void> _loadCurrentUser() async {
    try {
      print('开始加载用户信息...');
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('currentUsername') ?? '';
      final cachedUserId = prefs.getInt('current_user_id');
      
      print('当前登录用户名: $username');
      if (username.isEmpty) {
        print('没有找到登录用户');
        setState(() {
          _userId = 0;
          _username = '';
        });
        return;
      }

      // 如果有缓存的用户ID，先使用缓存
      if (cachedUserId != null) {
        setState(() {
          _userId = cachedUserId;
          _username = username;
        });
      }
      
      // 尝试从服务器获取最新用户信息
      final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
        ..whereEqualTo('u_name', username);
      
      // 设置超时
      final timeout = Future.delayed(const Duration(milliseconds: 300));
      
      try {
        final response = await Future.any([
          query.query(),
          timeout
        ]);
        
        if (response != null && response.success && response.results != null && response.results!.isNotEmpty) {
          final userObj = response.results!.first as ParseObject;
          final userId = userObj.get<int>('u_id') ?? 0;
          
          print('成功获取用户ID: $userId');
          
          // 更新缓存
          await prefs.setInt('current_user_id', userId);
          
          if (mounted) {
            setState(() {
              _userId = userId;
              _username = username;
            });
          }
        } else if (username == 'test' || username == 'admin') {
          print('使用默认测试用户ID: 1');
          await prefs.setInt('current_user_id', 1);
          if (mounted) {
            setState(() {
              _userId = 1;
              _username = username;
            });
          }
        }
      } catch (e) {
        print('获取用户信息超时或失败: $e');
        // 如果是测试用户，使用默认ID
        if (username == 'test' || username == 'admin') {
          print('使用默认测试用户ID: 1');
          await prefs.setInt('current_user_id', 1);
          if (mounted) {
            setState(() {
              _userId = 1;
              _username = username;
            });
          }
        }
      }
    } catch (e) {
      print('加载用户信息异常: $e');
    }
  }

  // 检查问题是否已被解决
  Future<void> _checkIfSolved() async {
    try {
      if (_userId > 0) {
        final questionId = widget.problem.get<int>('q_id') ?? 0;
        
        // 从本地缓存获取已完成的题目列表
        final prefs = await SharedPreferences.getInstance();
        final solvedProblemsJson = prefs.getString('solved_problems_${_userId}');
        
        if (solvedProblemsJson != null) {
          final solvedProblems = List<int>.from(json.decode(solvedProblemsJson));
          setState(() {
            _isSolved = solvedProblems.contains(questionId);
          });
        } else {
          setState(() {
            _isSolved = false;
          });
        }
      }
    } catch (e) {
      print('Error checking if solved: $e');
      setState(() {
        _isSolved = false;
      });
    }
  }

  Future<void> _loadQuestionDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingAnswers = true;
    });
    
    try {
      final questionId = widget.problem.get<int>('q_id') ?? 0;
      
      // 先尝试从缓存加载数据
      final cachedAnswers = await _answerRepository.getAnswersByQuestionId(questionId);
      
      if (!mounted) return;
      
      // 如果有缓存数据，立即显示
      if (cachedAnswers.isNotEmpty) {
        setState(() {
          _answers = cachedAnswers;
          _isLoadingAnswers = false;
        });
      }
      
      // 尝试从服务器加载最新数据
      final timeout = Future.delayed(const Duration(milliseconds: 300));
      
      try {
        final answers = await Future.any([
          _answerRepository.fetchLatestAnswers(questionId),  // 新方法，专门用于获取最新数据
          timeout,
        ]);
        
        if (!mounted) return;
        
        // 只有当获取到的新数据不为空时才更新
        if (answers != null && answers.isNotEmpty) {
          setState(() {
            _answers = answers;
          });
        }
      } catch (e) {
        print('加载最新评论超时或失败: $e');
      }
    } catch (e) {
      print('加载评论失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnswers = false;
        });
      }
    }
  }
  
  // 收藏或取消收藏问题
  Future<void> _toggleBookmark() async {
    if (_userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录后再收藏题目')),
      );
      return;
    }
    
    setState(() {
      _isBookmarking = true;
    });
    
    try {
      final questionId = widget.problem.get<int>('q_id') ?? 0;
      bool success;
      
      if (_isBookmarked) {
        // 取消收藏
        success = await _userinfoRepository.unbookmarkQuestion(_userId, questionId);
        if (success) {
          setState(() {
            _isBookmarked = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消收藏')),
          );
        }
      } else {
        // 添加收藏
        success = await _userinfoRepository.bookmarkQuestion(_userId, questionId);
        if (success) {
          setState(() {
            _isBookmarked = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已添加到收藏')),
          );
        }
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    } finally {
      setState(() {
        _isBookmarking = false;
      });
    }
  }
  
  // 标记题目为已完成
  Future<void> _markAsSolved() async {
    print('尝试标记题目为已完成，当前用户ID: $_userId');
    if (_userId == 0) {
      print('用户ID为0，提示需要登录');
      // 先再次尝试加载用户信息
      await _loadCurrentUser();
      
      // 如果仍然为0，则提示登录
      if (_userId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录后再标记题目')),
        );
        return;
      }
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final questionId = widget.problem.get<int>('q_id') ?? 0;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 添加一个回答，标记为已完成
      await _answerRepository.createAnswer(
        timestamp, 
        "我已经完成了这道题目！", 
        _userId, 
        0, 
        questionId,
        isSolved: true
      );
      
      // 更新本地缓存的已完成题目列表
      final prefs = await SharedPreferences.getInstance();
      final solvedProblemsJson = prefs.getString('solved_problems_${_userId}');
      final solvedProblems = solvedProblemsJson != null 
          ? List<int>.from(json.decode(solvedProblemsJson))
          : <int>[];
      
      if (!solvedProblems.contains(questionId)) {
        solvedProblems.add(questionId);
        await prefs.setString('solved_problems_${_userId}', json.encode(solvedProblems));
        
        // 更新用户统计数据
        await _userinfoRepository.updateSolvedProblems(_userId);
      }
      
      setState(() {
        _isSolved = true;
      });
      
      // 重新加载答案
      final updatedAnswers = await _answerRepository.getAnswersByQuestionId(questionId);
      if (mounted) {
        setState(() {
          _answers = updatedAnswers;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('恭喜你完成了这道题目！')),
      );
    } catch (e) {
      print('Error marking as solved: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 点赞回答
  Future<void> _likeAnswer(int answerId) async {
    if (_userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录后再点赞')),
      );
      return;
    }
    
    try {
      await _answerRepository.likeAnswer(answerId);
      
      // 重新加载回答
      _loadQuestionDetails();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('点赞成功')),
      );
    } catch (e) {
      print('Error liking answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('点赞失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.get<String>('q_title') ?? '未知标题'),
        actions: [
          _isBookmarking
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child: const SizedBox(
                    width: 20, 
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: _toggleBookmark,
                  tooltip: _isBookmarked ? '取消收藏' : '收藏题目',
                ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能即将上线')),
              );
            },
            tooltip: '分享题目',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProblemHeader(),
                  const SizedBox(height: 16.0),
                  _buildProblemDescription(),
                  const SizedBox(height: 24.0),
                  _buildSolveButton(),
                  const SizedBox(height: 24.0),
                  _buildDiscussionSection(),
                ],
              ),
            ),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }
  
  Widget _buildSolveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: _isSolved || _isSubmitting ? null : _markAsSolved,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.green,
          disabledBackgroundColor: _isSolved ? Colors.green.withOpacity(0.5) : null,
        ),
        child: _isSubmitting 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                _isSolved ? '已完成' : '标记为已完成',
                style: const TextStyle(fontSize: 16.0),
              ),
      ),
    );
  }

  Widget _buildProblemHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.problem.get<String>('difficulty') == "简单"
                    ? Colors.green[50]
                    : widget.problem.get<String>('difficulty') == "中等"
                        ? Colors.orange[50]
                        : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.problem.get<String>('difficulty') ?? '未知难度',
                style: TextStyle(
                  color: widget.problem.get<String>('difficulty') == "简单"
                      ? Colors.green[700]
                      : widget.problem.get<String>('difficulty') == "中等"
                          ? Colors.orange[700]
                          : Colors.red[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "通过率：${_calculateSuccessRate()}%",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${widget.problem.get<int>('submissions') ?? 0}人提交",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (widget.problem.get<List>('q_tags') ?? []).map<Widget>((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  String _calculateSuccessRate() {
    final submissionCount = widget.problem.get<int>('submissions') ?? 0;
    final successCount = widget.problem.get<int>('success_count') ?? 0;
    
    if (submissionCount <= 0) {
      return '0.0';
    }
    
    return (successCount / submissionCount * 100).toStringAsFixed(1);
  }

  Widget _buildProblemDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "题目描述",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.problem.get<String>('q_description') ?? '暂无描述',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "讨论区",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingAnswers && _answers.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (_answers.isEmpty)
          const Center(
            child: Text(
              "暂无讨论",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _answers.length,
            itemBuilder: (context, index) {
              final answer = _answers[index];
              final content = answer.get<String>('ainfo') ?? '';
              final userId = answer.get<int>('uid') ?? 0;
              final likeCount = answer.get<int>('alike') ?? 0;
              final answerId = answer.get<int>('a_id') ?? 0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _userinfoRepository.getUserName(userId),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                snapshot.data ?? '匿名用户',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_isLoadingAnswers)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () => _likeAnswer(answerId),
                                  child: Row(
                                    children: [
                                      Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('$likeCount', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "写下你的想法...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _userId == 0 ? null : _sendAnswer,
            child: const Text("发送"),
          ),
        ],
      ),
    );
  }
  
  // 发送回答
  Future<void> _sendAnswer() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容后再发送')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final questionId = widget.problem.get<int>('q_id') ?? 0;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 创建回答
      await _answerRepository.createAnswer(
        timestamp,
        message,
        _userId,
        0, // 初始点赞数为0
        questionId
      );
      
      // 清空输入框
      _messageController.clear();
      
      // 重新加载回答
      _loadQuestionDetails();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发送成功')),
      );
    } catch (e) {
      print('Error sending answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
