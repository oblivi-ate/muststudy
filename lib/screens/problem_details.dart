import 'package:flutter/material.dart';
import '../util/places.dart';

class ProblemDetails extends StatefulWidget {
  final Problem problem;

  const ProblemDetails({
    Key? key,
    required this.problem,
  }) : super(key: key);

  @override
  _ProblemDetailsState createState() => _ProblemDetailsState();
}

class _ProblemDetailsState extends State<ProblemDetails> {
  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'Python';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
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
                  _buildDifficultyAndStats(),
                  const SizedBox(height: 16.0),
                  _buildDescription(),
                  const SizedBox(height: 16.0),
                  _buildTestCases(),
                  const SizedBox(height: 16.0),
                  _buildTags(),
                  const SizedBox(height: 24.0),
                  _buildCodeEditor(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDifficultyAndStats() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: widget.problem.difficulty == "简单"
                ? Colors.green[100]
                : widget.problem.difficulty == "中等"
                    ? Colors.orange[100]
                    : Colors.red[100],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            widget.problem.difficulty,
            style: TextStyle(
              color: widget.problem.difficulty == "简单"
                  ? Colors.green[900]
                  : widget.problem.difficulty == "中等"
                      ? Colors.orange[900]
                      : Colors.red[900],
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Icon(Icons.check_circle_outline, size: 16.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(
          "通过率: ${widget.problem.successRate.toStringAsFixed(1)}%",
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(width: 16.0),
        Icon(Icons.person_outline, size: 16.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(
          "提交: ${widget.problem.solvedCount}",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "题目描述",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          widget.problem.description,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildTestCases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "示例",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "输入：${widget.problem.testCases['input'].toString()}",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "输出：${widget.problem.testCases['output'].toString()}",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.problem.tags.map((tag) {
        return Chip(
          label: Text(tag),
          backgroundColor: Colors.blue[50],
          labelStyle: TextStyle(color: Colors.blue[900]),
        );
      }).toList(),
    );
  }

  Widget _buildCodeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "编程语言：",
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(width: 8.0),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: ['Python', 'Java', 'C++', 'JavaScript']
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 300.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            controller: _codeController,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
              hintText: '在这里编写你的代码...',
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // 运行测试用例
              },
              child: const Text('运行'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // 提交代码
              },
              child: const Text('提交'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
