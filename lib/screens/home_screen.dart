import 'package:flutter/material.dart';
import 'forum_screen.dart';
import '../widgets/ai_assistant.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MustStudy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "欢迎来到 MustStudy",
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildFeatureGrid(context),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildFeatureCard(
          context,
          title: "学习论坛",
          description: "与同学交流学习经验",
          icon: Icons.forum_outlined,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForumScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          title: "AI 助手",
          description: "智能解答你的问题",
          icon: Icons.psychology_outlined,
          color: Colors.green,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AIAssistantDialog(),
            );
          },
        ),
        _buildFeatureCard(
          context,
          title: "学习资源",
          description: "海量优质学习资料",
          icon: Icons.school_outlined,
          color: Colors.orange,
          onTap: () {
            // TODO: 导航到学习资源页面
          },
        ),
        _buildFeatureCard(
          context,
          title: "练习题库",
          description: "在线刷题提升能力",
          icon: Icons.edit_note_outlined,
          color: Colors.purple,
          onTap: () {
            // TODO: 导航到练习题库页面
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.0,
                  color: color,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "最近活动",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.forum,
                color: Colors.blue,
                title: "论坛新增热门讨论",
                subtitle: "数据结构与算法学习经验分享",
                time: "10分钟前",
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.psychology,
                color: Colors.green,
                title: "AI助手功能更新",
                subtitle: "支持代码分析与优化建议",
                time: "2小时前",
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.school,
                color: Colors.orange,
                title: "新增精品课程",
                subtitle: "Web全栈开发实战教程",
                time: "昨天",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 24.0,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12.0,
        ),
      ),
    );
  }
} 