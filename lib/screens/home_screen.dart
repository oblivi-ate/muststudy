import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'forum_screen.dart';
import '../widgets/ai_assistant.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildQuickActions(context),
              _buildPopularDestinations(context),
              _buildRecentActivities(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Text(
                '李同学',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(Icons.search, color: Colors.grey[400]),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索题目、资源...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.forum_outlined, 'label': '学习论坛', 'color': AppColors.coral},
      {'icon': Icons.chat_outlined, 'label': 'AI助手', 'color': AppColors.mint},
      {'icon': Icons.library_books_outlined, 'label': '学习资源', 'color': AppColors.skyBlue},
      {'icon': Icons.assignment_outlined, 'label': '练习题库', 'color': AppColors.peach},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速入口',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((action) {
              return InkWell(
                onTap: () {
                  if (action['label'] == '学习论坛') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForumScreen()),
                    );
                  } else if (action['label'] == 'AI助手') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AIAssistantDialog(),
                    );
                  }
                },
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: action['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门推荐',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDestinationCard(
                  context,
                  title: '算法基础',
                  subtitle: '数据结构与算法',
                  gradient: AppColors.primaryGradient,
                  icon: Icons.code,
                ),
                _buildDestinationCard(
                  context,
                  title: '面试技巧',
                  subtitle: '求职必备',
                  gradient: AppColors.secondaryGradient,
                  icon: Icons.work,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近活动',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.assignment_turned_in,
            title: '完成每日练习',
            subtitle: '算法基础 - 链表',
            time: '2小时前',
            color: AppColors.coral,
          ),
          _buildActivityCard(
            icon: Icons.forum,
            title: '发布了问题',
            subtitle: '如何理解动态规划？',
            time: '4小时前',
            color: AppColors.mint,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
} 