import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/achievement.dart';
import '../repositories/Achievement_repository.dart';
import '../repositories/Userinfo_respositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AchievementListScreen extends StatefulWidget {
  const AchievementListScreen({Key? key}) : super(key: key);

  @override
  State<AchievementListScreen> createState() => _AchievementListScreenState();
}

class _AchievementListScreenState extends State<AchievementListScreen> {
  final AchievementRepository _achievementRepository = AchievementRepository();
  final UserinfoRepository _userinfoRepository = UserinfoRepository();
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;
  int _userId = 0;
  int _totalAchievements = 0;
  int _unlockedAchievements = 0;
  
  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }
  
  Future<void> _loadAchievements() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取当前用户ID
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('currentUsername') ?? '';
      if (username.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 获取用户ID
      _userId = username == 'test' ? 1 : (username == 'admin' ? 2 : 0);
      
      if (_userId > 0) {
        // 获取用户统计数据
        final stats = await _userinfoRepository.getUserStatistics(_userId);
        final solvedProblems = stats['solvedProblems'] ?? 0;
        
        // 获取并更新成就
        await _achievementRepository.checkAndUpdateAchievements(_userId, solvedProblems);
        final achievements = await _achievementRepository.getAchievements();
        
        if (mounted) {
          setState(() {
            _achievements = achievements;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('加载成就失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFE4D4),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4D4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '探险成就',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '正在加载成就数据...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
      : _userId == 0
          ? const Center(child: Text('请先登录'))
          : _achievements.isEmpty
              ? const Center(child: Text('暂无成就'))
              : Stack(
                  children: [
                    Container(
                      color: const Color(0xFFFFE4D4),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: _buildAchievementStats(),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F3),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: _buildUserAchievements(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildAchievementStats() {
    final completionPercentage = _totalAchievements > 0 
        ? (_unlockedAchievements / _totalAchievements * 100).toStringAsFixed(2) 
        : '0.00';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('已获得成就', '$_unlockedAchievements/$_totalAchievements', Icons.emoji_events_outlined),
        Container(
          width: 1,
          height: 40,
          color: Colors.black12,
        ),
        _buildStatItem('完成度', '$completionPercentage%', Icons.pie_chart_outline),
        Container(
          width: 1,
          height: 40,
          color: Colors.black12,
        ),
        _buildStatItem('探险点数', '${_unlockedAchievements * 100}', Icons.star_outline),
      ],
    );
  }
  
  Widget _buildUserAchievements() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        final progress = achievement['progress'] ?? 0;
        final total = achievement['total'] ?? 1;
        final percent = (progress / total * 100).clamp(0, 100);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (achievement['unlocked'] == false)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: achievement['color']?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        achievement['unlocked'] == true
                            ? Icons.emoji_events
                            : Icons.lock_outline,
                        color: achievement['unlocked'] == true
                            ? Colors.amber
                            : Colors.grey,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: achievement['unlocked'] == true
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement['description'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: progress / total,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement['unlocked'] == true
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '进度: $progress/$total (${percent.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (achievement['unlocked'] == false)
                      const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _updateAchievementStats(List<Map<String, dynamic>> achievements) {
    _totalAchievements = achievements.length;
    _unlockedAchievements = achievements.where((a) => a['unlocked'] == true).length;
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case '入门':
        return Colors.green;
      case '进阶':
        return Colors.blue;
      case '专业':
        return Colors.purple;
      case '高级':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 