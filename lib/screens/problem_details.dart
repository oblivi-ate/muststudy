import 'package:flutter/material.dart';
import '../util/places.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../repositories/Question_respositories.dart';
import '../repositories/Q_tag_respositories.dart';

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
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionDetails();
  }

  Future<void> _loadQuestionDetails() async {
    try {
      // 加载问题详情
      final questions = await _questionRepository.fetchQuestions();
      final questionDetails = widget.problem;

      // 加载问题标签
      final tags = await _qtagRepository.fetchQtag();
      if (tags != null) {
        final questionTags = tags.where((tag) => 
          tag.get<int>('q_id') == widget.problem.objectId
        ).toList();
      }
    } catch (e) {
      print('Error loading question details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.get<String>('q_title') ?? '未知标题'),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
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
              "通过率：${(widget.problem.get<num>('success_rate') ?? 0).toStringAsFixed(1)}%",
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
        const Center(
          child: Text(
            "暂无讨论",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
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
            onPressed: () {
              // TODO: 实现发送功能
            },
            child: const Text("发送"),
          ),
        ],
      ),
    );
  }
}
