import 'package:flutter/material.dart';
import '../repositories/Question_respositories.dart';
import '../repositories/Q_tag_respositories.dart';

// 这是一个示例类，用于演示如何正确上传题目
class ExampleUpload {
  final QuestionRepository _questionRepository = QuestionRepository();
  final QtagRepository _qtagRepository = QtagRepository();

  // 示例上传方法
  Future<void> uploadExampleQuestion(BuildContext context) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 生成唯一的问题ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 创建示例题目内容
      final title = "数据结构：二叉树的遍历算法实现";
      final content = """
请实现二叉树的前序、中序和后序遍历算法，并分析各自的时间复杂度和空间复杂度。

要求：
1. 分别使用递归和非递归方式实现
2. 对于非递归实现，分析栈的使用情况
3. 分析各种遍历方法的应用场景
4. 提供完整的代码实现和测试用例
      """;
      final description = "二叉树遍历算法的实现与分析";
      final difficulty = "中等";
      final tags = ["数据结构", "算法", "二叉树"];
      final college = "创新工程学院";

      // 1. 创建问题
      print('开始创建示例题目...');
      await _questionRepository.createQuestionItem(
        timestamp,  // 问题ID 
        1,          // 用户ID
        title,      // 标题
        content,    // 内容
        0,          // 初始点赞数
        description, // 描述
        difficulty, // 难度
        tags,       // 标签
        college     // 学院
      );
      print('示例题目创建成功');

      // 2. 保存标签
      print('开始添加标签...');
      await _qtagRepository.createQtagItem(timestamp, tags);
      print('标签添加成功');

      // 3. 同时保存到本地存储作为备份
      await _questionRepository.saveQuestionLocally(
        timestamp, 
        1, 
        title,
        content,
        description, 
        difficulty,
        tags,
        college
      );
      print('题目已保存到本地存储');

      // 关闭加载对话框
      Navigator.pop(context);
      
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('示例题目上传成功！请刷新题目列表查看')),
      );
      
    } catch (e) {
      print('上传示例题目失败: $e');
      
      // 关闭加载对话框
      Navigator.pop(context);
      
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    }
  }
} 