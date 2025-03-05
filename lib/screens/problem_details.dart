import 'package:flutter/material.dart';
import '../util/places.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _messageController = TextEditingController();
  String _selectedLanguage = 'Python';
  bool _isLiked = false;
  bool _isBookmarked = false;
  final List<Reply> _replies = [
    Reply(
      id: '1',
      authorName: '王同学',
      authorAvatar: 'https://ui-avatars.com/api/?name=王同学&background=random',
      content: '我觉得这道题可以用哈希表来解决，这样可以将时间复杂度降到O(n)。',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      codeSnippet: '''def twoSum(nums, target):
    hash_map = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in hash_map:
            return [hash_map[complement], i]
        hash_map[num] = i
    return []''',
      codeLanguage: 'python',
      likes: 15,
      isAccepted: true,
      subReplies: [
        SubReply(
          id: '1-1',
          authorName: '张同学',
          authorAvatar: 'https://ui-avatars.com/api/?name=张同学&background=random',
          content: '这个解法非常清晰，请问时间复杂度是怎么分析的？',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          likes: 3,
          replyToName: '王同学',
        ),
        SubReply(
          id: '1-2',
          authorName: '王同学',
          authorAvatar: 'https://ui-avatars.com/api/?name=王同学&background=random',
          content: '因为我们只需要遍历一次数组，而哈希表的查找是O(1)的，所以总的时间复杂度是O(n)。',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likes: 5,
          replyToName: '张同学',
        ),
      ],
    ),
    Reply(
      id: '2',
      authorName: '李同学',
      authorAvatar: 'https://ui-avatars.com/api/?name=李同学&background=random',
      content: '这是我的解题思路，我还录制了一段语音讲解。',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      audioUrl: 'audio_explanation.mp3',
      images: ['solution_diagram.png'],
      likes: 8,
      isAccepted: false,
      subReplies: [],
    ),
  ];

  String? _replyingTo;
  Reply? _selectedReply;

  void _showReplyDialog(BuildContext context, {Reply? parentReply, String? replyToName}) {
    setState(() {
      _replyingTo = replyToName;
      _selectedReply = parentReply;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _replyingTo != null ? '回复 $_replyingTo' : '添加回复',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedReply != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(_selectedReply!.authorAvatar),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedReply!.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_selectedReply!.content),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '写下你的回复...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image_outlined),
                          onPressed: () {
                            // TODO: 实现图片上传功能
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic_none),
                          onPressed: () {
                            // TODO: 实现语音录制功能
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.code),
                          onPressed: () {
                            // TODO: 实现代码编辑功能
                          },
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: 实现发送回复功能
                            Navigator.pop(context);
                          },
                          child: const Text('发送'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
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
                  _buildTopInfo(),
                  const SizedBox(height: 16.0),
                  _buildDescription(),
                  const SizedBox(height: 16.0),
                  _buildTestCases(),
                  const SizedBox(height: 24.0),
                  _buildReplies(),
                ],
              ),
            ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildTopInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.problem.authorAvatar ?? 
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.problem.author ?? "Unknown")}'),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.problem.author ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.problem.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isLiked = !_isLiked;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: _isLiked ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.problem.likes ?? 0}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.problem.bookmarks ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildReplies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "回复",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(${_replies.length})",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        ..._replies.map((reply) => _buildReplyItem(reply)).toList(),
      ],
    );
  }

  Widget _buildReplyItem(Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(reply.authorAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reply.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (reply.isAccepted)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '已采纳',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(reply.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(reply.content),
          if (reply.codeSnippet != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          reply.codeLanguage ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          // TODO: 实现代码复制功能
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reply.codeSnippet!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (reply.images != null && reply.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reply.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(reply.images![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (reply.audioUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '播放语音',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () {
                  // TODO: 实现点赞功能
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reply.likes}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _showReplyDialog(context, parentReply: reply, replyToName: reply.authorName),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '回复',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reply.subReplies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(left: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reply.subReplies.map((subReply) => _buildSubReplyItem(subReply, reply)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubReplyItem(SubReply subReply, Reply parentReply) {
    return InkWell(
      onTap: () => _showReplyDialog(context, parentReply: parentReply, replyToName: subReply.authorName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(subReply.authorAvatar),
                ),
                const SizedBox(width: 8),
                Text(
                  subReply.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' 回复 ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  subReply.replyToName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subReply.content),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormat('MM-dd HH:mm').format(subReply.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO: 实现点赞功能
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subReply.likes}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '回复',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (subReply != parentReply.subReplies.last)
              const Divider(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
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
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () {
              // TODO: 实现图片上传功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic_none),
            onPressed: () {
              // TODO: 实现语音录制功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              // TODO: 实现代码编辑功能
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '写下你的回复...',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现发送回复功能
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
