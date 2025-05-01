import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../repositories/Q_tag_respositories.dart';
import '../repositories/Question_respositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ForumUpdateQuestionsScreen extends StatefulWidget {
  const ForumUpdateQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<ForumUpdateQuestionsScreen> createState() => _ForumUpdateQuestionsScreenState();
}

class _ForumUpdateQuestionsScreenState extends State<ForumUpdateQuestionsScreen> {
  // 学院和专业映射
  final List<String> _colleges = ['创新工程学院', '商学院', '法学院', '医学院'];
  // 专业映射
  final Map<String, List<String>> _majorMap = {
    '创新工程学院': ['计算机科学', '电子信息', '软件工程'],
    '商学院': ['A专业', 'B专业', 'C专业'],
    '法学院': ['A专业', 'B专业', 'C专业'],
    '医学院': ['A专业', 'B专业', 'C专业'],
  };
  final QtagRepository _qtagRepository = QtagRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  List<String> _existingTags = [];

  String _selectedCollege = '创新工程学院';
  String _selectedMajor = '计算机科学';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  List<String> _attributeTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 拉取已有标签用于自动补全
    _qtagRepository.fetchQtag().then((list) {
      if (list != null) {
        setState(() {
          _existingTags = list
            .expand((obj) => obj.get<List>('q_tags')?.cast<String>() ?? <String>[]) // 确保为 List<String>
            .toSet()
            .toList();
        });
      }
    });
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      print('选择图片失败: $e');
    }
  }

  // 添加属性标签
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_attributeTags.contains(tag)) {
      setState(() {
        _attributeTags.add(tag);
        _tagController.clear();
      });
    }
  }

  // 移除属性标签
  void _removeTag(String tag) {
    setState(() {
      _attributeTags.remove(tag);
    });
  }

  // 删除选中图片
  void _removeImage(XFile image) {
    setState(() {
      _images.remove(image);
    });
  }

  // 提交操作
  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _informationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填字段')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 获取当前用户ID
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('currentUsername') ?? '';
      int userId = 1; // 默认用户ID

      if (username.isNotEmpty) {
        final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
          ..whereEqualTo('u_name', username);
        final response = await query.query();
        
        if (response.success && response.results != null && response.results!.isNotEmpty) {
          final userObj = response.results!.first as ParseObject;
          userId = userObj.get<int>('u_id') ?? 1;
        }
      }

      // 生成唯一问题ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 创建问题
      await _questionRepository.createQuestionItem(
        timestamp,
        userId,
        _titleController.text,
        _informationController.text,
        0, // 初始点赞数为0
        _descriptionController.text,
        '中等', // 默认难度
        _attributeTags,
        _selectedCollege
      );

      // 为问题添加标签
      await _qtagRepository.createQtagItem(timestamp, _attributeTags);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('题目上传成功！')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('上传题目失败: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _informationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传题目'),
        backgroundColor: const Color(0xFFFFE4D4),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('题目标题:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入题目标题',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('选择学院:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _colleges.map((c) => ChoiceChip(
                            label: Text(c),
                            selected: _selectedCollege == c,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCollege = c;
                                // 更新专业默认值
                                _selectedMajor = _majorMap[_selectedCollege]!.first;
                              });
                            },
                            selectedColor: Colors.blue.shade100,
                          )).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('选择专业:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _majorMap[_selectedCollege]!.map((m) => ChoiceChip(
                            label: Text(m),
                            selected: _selectedMajor == m,
                            onSelected: (selected) => setState(() {
                              _selectedMajor = m;
                            }),
                            selectedColor: Colors.blue.shade100,
                          )).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('题目描述:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入题目描述',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('题目内容:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _informationController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入题目内容',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('上传图片:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // 已选图片预览
                        ..._images.map((img) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(img),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )),
                        // 添加图片占位
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('属性标签 (# 开头自动补全):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        final text = value.text;
                        if (!text.startsWith('#') || text.length < 2) return const Iterable<String>.empty();
                        final keyword = text.substring(1).toLowerCase();
                        return _existingTags
                          .where((tag) => tag.toLowerCase().contains(keyword))
                          .map((tag) => '#$tag');
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        _tagController.text = controller.text;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '#输入标签',
                          ),
                          onSubmitted: (_) => _addTag(),
                        );
                      },
                      onSelected: (String selection) {
                        _tagController.text = selection;
                        _addTag();
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _attributeTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('上传题目'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
