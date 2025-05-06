import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../repositories/Q_tag_respositories.dart';
import '../repositories/Question_respositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:convert';

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
  List<String> _attributeTags = <String>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 拉取已有标签用于自动补全
    _qtagRepository.fetchQtag().then((list) {
      if (list != null) {
        setState(() {
          _existingTags = list
            .map((obj) => obj.get<String>('q_tags') ?? '') // 获取标签字符串
            .where((tagStr) => tagStr.isNotEmpty) // 过滤空字符串
            .expand((tagStr) => tagStr.split(',')) // 分割成单个标签
            .toSet() // 去重
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

  // 添加属性标签 - 彻底重写此方法
  void _addTag() {
    // 获取用户输入
    final String inputTag = _tagController.text.trim();
    print('【标签调试】原始输入: "$inputTag"');
    
    // 检查是否为空
    if (inputTag.isEmpty) {
      print('【标签调试】输入为空，不添加标签');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签不能为空')),
      );
      return;
    }
    
    // 处理标签
    String cleanTag = inputTag;
    
    // 移除#前缀
    if (cleanTag.startsWith('#')) {
      cleanTag = cleanTag.substring(1);
      print('【标签调试】移除#前缀后: "$cleanTag"');
      }
      
    // 处理空标签
    if (cleanTag.isEmpty) {
      print('【标签调试】处理后标签为空');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签内容不能为空')),
      );
      return;
    }
    
    // 处理数字标签 - 直接转为字符串确保类型一致
    final String finalTag = cleanTag.toString();
    print('【标签调试】最终标签: "$finalTag", 类型: ${finalTag.runtimeType}');
    
    // 检查数字标签 - 专门处理"250"这样的纯数字标签
    bool isNumeric = int.tryParse(finalTag) != null;
    if (isNumeric) {
      print('【标签调试】检测到数字标签: $finalTag, 已确保字符串类型');
    }
    
    // 检查重复
    if (_attributeTags.contains(finalTag)) {
      print('【标签调试】标签已存在');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标签"$finalTag"已存在')),
      );
        return;
      }
      
    // 添加到列表
        setState(() {
      _attributeTags.add(finalTag);
      print('【标签调试】成功添加标签: "$finalTag"');
      print('【标签调试】当前列表: $_attributeTags');
    });
    
    // 清空输入框
          _tagController.clear();
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('成功添加标签: $finalTag'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 测试标签状态 - 添加此方法用于调试
  void _debugTags() {
    print("\n【标签调试】===== 测试标签状态 =====");
    print("当前标签列表: $_attributeTags");
    
    if (_attributeTags.isEmpty) {
      print("标签列表为空");
    } else {
      for (int i = 0; i < _attributeTags.length; i++) {
        final tag = _attributeTags[i];
        print("标签[$i]: \"$tag\", 类型: ${tag.runtimeType}, 是数字? ${int.tryParse(tag) != null}");
    }
    }
    
    print("当前输入框文本: \"${_tagController.text}\"");
    print("【标签调试】===== 测试结束 =====\n");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('调试信息已输出到控制台'),
        duration: const Duration(seconds: 1),
      ),
    );
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
    print('开始提交表单，验证输入...');
    print('课程编号: ${_titleController.text}');
    print('题目内容: ${_informationController.text}');
    print('学院: $_selectedCollege');
    print('专业: $_selectedMajor');
    print('原始标签列表: $_attributeTags');
    
    if (_titleController.text.isEmpty || _informationController.text.isEmpty) {
      print('验证失败：必填字段为空');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填字段（课程编号和题目内容）')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 生成唯一问题ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    try {
      print('开始上传题目数据...');
      // 获取当前用户ID
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('currentUsername') ?? '';
      print('当前用户: $username');
      int userId = 1; // 默认用户ID

      if (username.isNotEmpty) {
        try {
          final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
            ..whereEqualTo('u_name', username);
          
          final userQueryTimeout = Future.delayed(const Duration(milliseconds: 300));
          final userResponse = await Future.any([query.query(), userQueryTimeout]);
          
          if (userResponse is ParseResponse && userResponse.success && 
              userResponse.results != null && userResponse.results!.isNotEmpty) {
            final userObj = userResponse.results!.first as ParseObject;
            userId = userObj.get<int>('u_id') ?? 1;
          }
        } catch (e) {
          print('获取用户ID失败，使用默认ID: $e');
        }
      }

      // 重新创建标签列表，确保所有标签都是字符串类型
      final List<String> finalTags = <String>[];
      
      // 如果没有添加标签，使用默认标签
      if (_attributeTags.isEmpty) {
        finalTags.add('默认标签');
        print('【标签调试】使用默认标签，因为没有添加标签');
      } else {
        // 打印当前属性标签列表，检查每个标签的类型
        print('【标签调试】提交时的属性标签列表: $_attributeTags');
        for (int i = 0; i < _attributeTags.length; i++) {
          print('【标签调试】属性标签[$i]: "${_attributeTags[i]}", 类型: ${_attributeTags[i].runtimeType}');
        }

        // 处理每个标签，确保正确格式
        for (int i = 0; i < _attributeTags.length; i++) {
          // 获取原始标签并确保是字符串类型
          String tag = _attributeTags[i].toString();
          
          // 移除#前缀
          if (tag.startsWith('#')) {
            tag = tag.substring(1);
          }
          
          // 如果标签非空，则添加到最终列表
          if (tag.isNotEmpty) {
            // 确保数字也处理为字符串
            String processedTag = tag.toString();
            finalTags.add(processedTag);
            print('【标签调试】添加标签[$i]: "$processedTag"');
          }
        }
        
        // 如果所有标签都被过滤掉了，添加默认标签
        if (finalTags.isEmpty) {
          finalTags.add('默认标签');
          print('【标签调试】所有标签都被过滤，使用默认标签');
        }
      }
      
      print('【标签调试】最终标签列表 (${finalTags.length}个): $finalTags');
      
      // 直接打印所有标签的类型
      for (int i = 0; i < finalTags.length; i++) {
        print('【标签调试】最终标签[$i]: "${finalTags[i]}", 类型: ${finalTags[i].runtimeType}');
      }

      // 直接保存到本地，跳过云数据库保存
      print('保存到本地存储...');
      await _questionRepository.saveQuestionLocally(
        timestamp, 
        userId, 
        _titleController.text,
        _informationController.text,
        _titleController.text, // 使用标题作为描述
        '中等',
        finalTags,
        _selectedCollege
      );
      print('本地保存成功');

      if (!mounted) return;

      // 显示成功信息并包含标签内容
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('题目已成功保存！标签: ${finalTags.join(", ")}')),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      print('上传题目失败，详细错误: $e');
      print('错误堆栈: ${StackTrace.current}');
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
                    const Text('课程编号: (必填)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入课程编号',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('选择学院: (必填)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '选择学院'),
                      value: _selectedCollege,
                      items: _colleges.map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCollege = value;
                            _selectedMajor = _majorMap[_selectedCollege]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('选择专业: (必填)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '选择专业'),
                      value: _selectedMajor,
                      items: _majorMap[_selectedCollege]!.map((m) => DropdownMenuItem<String>(
                            value: m,
                            child: Text(m),
                          )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMajor = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('题目内容: (必填)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    const Text('上传图片: (可选)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    const Text('添加标签: (可选)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        final text = value.text.trim();
                        
                        // 如果输入为空，不显示补全选项
                        if (text.isEmpty) return const Iterable<String>.empty();
                        
                        // 处理带#和不带#的情况
                        String searchText = text.toLowerCase();
                        bool hasHash = searchText.startsWith('#');
                        if (hasHash && searchText.length > 1) {
                          searchText = searchText.substring(1);
                        }
                        
                        // 从已有标签中查找匹配项
                        return _existingTags
                          .where((tag) => tag.toLowerCase().contains(searchText))
                          .map((tag) => hasHash ? '#$tag' : tag);
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                              // 这里是问题所在 - 我们需要确保_tagController和controller保持同步
                              // 但不能直接赋值，因为这会导致循环引用
                              
                              // 清除之前的监听器
                              controller.removeListener(() {});
                              
                              // 同步初始值
                              if (controller.text != _tagController.text) {
                                controller.text = _tagController.text;
                              }
                              
                              // 监听输入框变化，同步到_tagController
                              controller.addListener(() {
                                if (_tagController.text != controller.text) {
                        _tagController.text = controller.text;
                                  print('控制器文本已同步: ${controller.text}');
                                }
                              });
                              
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '输入标签 (可以使用#前缀)',
                                  helperText: '数字标签如: 250 或 #SE250',
                          ),
                                onSubmitted: (_) {
                                  print('提交时的控制器文本: ${controller.text}, _tagController: ${_tagController.text}');
                                  _addTag();
                                },
                        );
                      },
                      onSelected: (String selection) {
                              print('选择了自动完成项: $selection');
                        _tagController.text = selection;
                        _addTag();
                      },
                    ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            print('添加按钮点击 - 当前标签文本: ${_tagController.text}');
                            _addTag();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFFF9E80),
                          ),
                          child: const Text('添加', style: TextStyle(color: Colors.white)),
                        ),
                        // 添加调试按钮
                        IconButton(
                          onPressed: _debugTags,
                          icon: const Icon(Icons.bug_report),
                          tooltip: '测试标签状态',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // 显示已添加标签
                    if (_attributeTags.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('还没有添加标签，题目将使用"默认标签"', 
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('已添加 ${_attributeTags.length} 个标签：',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _attributeTags.map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: const Color(0xFFFFE4D4),
                        labelStyle: const TextStyle(color: Colors.black87),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        '添加标签可以让你的题目更容易被发现',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        '注意：无需上传图片也可以提交题目',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('上传题目'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading == false)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            // 设置默认值并强制提交
                            print('使用默认值强制提交');
                            if (_titleController.text.isEmpty) {
                              _titleController.text = 'SE462-默认题目';
                            }
                            if (_informationController.text.isEmpty) {
                              _informationController.text = '默认题目内容';
                            }
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              // 生成唯一问题ID
                              final timestamp = DateTime.now().millisecondsSinceEpoch;
                              print('生成题目ID: $timestamp');
                              
                              // 重新创建标签列表，确保所有标签都是字符串类型
                              final List<String> finalTags = <String>[];
                              
                              // 如果没有添加标签，使用默认标签
                              if (_attributeTags.isEmpty) {
                                finalTags.add('默认标签');
                                print('【标签调试】使用默认标签，因为没有添加标签');
                              } else {
                                // 打印当前属性标签列表，检查每个标签的类型
                                print('【标签调试】提交时的属性标签列表: $_attributeTags');
                                for (int i = 0; i < _attributeTags.length; i++) {
                                  print('【标签调试】属性标签[$i]: "${_attributeTags[i]}", 类型: ${_attributeTags[i].runtimeType}');
                                }

                                // 处理每个标签，确保正确格式
                                for (int i = 0; i < _attributeTags.length; i++) {
                                  // 获取原始标签并确保是字符串类型
                                  String tag = _attributeTags[i].toString();
                                  
                                  // 移除#前缀
                                  if (tag.startsWith('#')) {
                                    tag = tag.substring(1);
                                  }
                                  
                                  // 如果标签非空，则添加到最终列表
                                  if (tag.isNotEmpty) {
                                    // 确保数字也处理为字符串
                                    String processedTag = tag.toString();
                                    finalTags.add(processedTag);
                                    print('【标签调试】添加标签[$i]: "$processedTag"');
                                  }
                                }
                                
                                // 如果所有标签都被过滤掉了，添加默认标签
                                if (finalTags.isEmpty) {
                                  finalTags.add('默认标签');
                                  print('【标签调试】所有标签都被过滤，使用默认标签');
                                }
                              }
                              
                              print('【标签调试】最终标签列表 (${finalTags.length}个): $finalTags');
                              
                              // 直接打印所有标签的类型
                              for (int i = 0; i < finalTags.length; i++) {
                                print('【标签调试】最终标签[$i]: "${finalTags[i]}", 类型: ${finalTags[i].runtimeType}');
                              }
                              
                              // 使用新方法直接保存到本地
                              await _questionRepository.saveQuestionLocally(
                                timestamp, 
                                1, // 默认用户ID
                                _titleController.text,
                                _informationController.text,
                                _titleController.text, // 使用标题作为描述
                                '中等',
                                finalTags,
                                _selectedCollege
                              );
                              
                              print('本地保存成功');
                              
                              // 返回上一页
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('题目本地保存成功！标签: ${finalTags.join(", ")}')),
                              );
                              Navigator.pop(context, true);
                            } catch (e) {
                              print('本地保存失败: $e');
                              if (!mounted) return;
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('本地保存失败: $e')),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                          ),
                          child: const Text('如果正常上传失败，点击这里尝试本地保存'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
