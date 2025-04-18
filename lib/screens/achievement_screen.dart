import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../models/achievement.dart';
import '../theme/app_theme.dart';
import 'achievement_list_screen.dart';
import '../repositories/Achievement_repository.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final AchievementRepository _achievementRepository = AchievementRepository();
  List<Achievement> _achievements = [];
  Achievement? _currentAchievement;
  final AchievementManager _manager = AchievementManager();

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      // 临时使用固定用户ID，实际应该从登录用户获取
      final achievements = await _achievementRepository.fetchAchievements(1);
      setState(() {
        _achievements = achievements;
        _currentAchievement = achievements.isNotEmpty ? achievements.first : null;
      });
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFE4D4),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4D4),
        elevation: 0,
        title: const Text(
          '学习达人',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFFFE4D4),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "正在进行的探索",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCurrentAchievement(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAchievementWall(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAchievement() {
    if (_currentAchievement == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final achievement = _currentAchievement!;
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              // 根据成就类型设置不同的背景
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getBackgroundColors(achievement.get<String>('title') ?? ''),
                  ),
                ),
              ),
              // 根据成就类型设置不同的山脉剪影
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getMountainColors(achievement.get<String>('title') ?? ''),
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _getMountainPainter(achievement.get<String>('title') ?? ''),
                    ),
                  ),
                ),
              ),
              // 根据成就类型设置不同的路径
              CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _getPathPainter(
                  achievement.get<String>('title') ?? '',
                  achievement.get<int>('progress') / achievement.get<int>('goal'),
                ),
              ),
              // 关键节点标记
              // TODO: 实现里程碑显示
              // 需要从Parse后端获取里程碑数据
            ],
          ),
        ),
        const SizedBox(height: 15),
        // 信息卡片部分保持不变
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events, // 使用默认图标，后续可从icon_name获取对应图标
                    size: 20,
                    color: Colors.amber.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      achievement.get<String>('title') ?? '未知成就',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "已完成 ${achievement.currentProgress}/${achievement.totalGoal} ${achievement.description}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: achievement.currentProgress / achievement.totalGoal,
                  backgroundColor: Colors.grey[200]?.withOpacity(0.8),
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.color.withOpacity(0.9)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 根据成就标题获取背景颜色
  List<Color> _getBackgroundColors(String title) {
    if (title.contains('长城')) {
      return [
        Color(0xFF8B4513),  // 土褐色
        Color(0xFF654321),  // 深褐色
      ];
    } else if (title.contains('喜马拉雅')) {
      return [
        Color(0xFF87CEEB),  // 天空蓝
        Color(0xFF1E90FF),  // 深蓝
      ];
    } else if (title.contains('金字塔')) {
      return [
        Color(0xFFFFD700),  // 金色
        Color(0xFFDAA520),  // 金棕色
      ];
    }
    // 默认颜色
    return [
      Color(0xFF4A90E2),
      Color(0xFF2C3E50),
    ];
  }

  // 根据成就标题获取山脉颜色
  List<Color> _getMountainColors(String title) {
    if (title.contains('长城')) {
      return [
        Color(0xFF8B4513),  // 土褐色
        Color(0xFF654321),  // 深褐色
      ];
    } else if (title.contains('喜马拉雅')) {
      return [
        Color(0xFF2B4C7E),  // 深蓝
        Color(0xFF1B365C),  // 更深的蓝
      ];
    } else if (title.contains('金字塔')) {
      return [
        Color(0xFFDAA520),  // 金棕色
        Color(0xFFB8860B),  // 暗金色
      ];
    }
    // 默认颜色
    return [
      Color(0xFF34495E),
      Color(0xFF2C3E50),
    ];
  }

  // 根据成就标题获取山脉绘制器
  CustomPainter _getMountainPainter(String title) {
    if (title.contains('长城')) {
      return GreatWallPainter();
    } else if (title.contains('喜马拉雅')) {
      return HimalayaPainter();
    } else if (title.contains('金字塔')) {
      return PyramidPainter();
    }
    return MountainSilhouettePainter();
  }

  // 根据成就标题获取路径绘制器
  CustomPainter _getPathPainter(String title, double progress) {
    if (title.contains('长城')) {
      return GreatWallPathPainter(progress: progress);
    } else if (title.contains('喜马拉雅')) {
      return HimalayaPathPainter(progress: progress);
    } else if (title.contains('金字塔')) {
      return PyramidPathPainter(progress: progress);
    }
    return MountainPathPainter(progress: progress);
  }

  Widget _buildMilestone(double position, String requirement, String name) {
    return Positioned(
      left: position * 300 - 30,
      top: (1 - position) * 150,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              requirement,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementWall() {
    final achievements = _manager.achievements;

    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '探险成就墙',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementListScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.5,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(achievement.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(achievement.description),
                            const SizedBox(height: 10),
                            Text(
                              '进度: ${achievement.currentProgress}/${achievement.totalGoal}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _manager.setCurrentAchievement(achievement);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('设为当前探索'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
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
                        if (achievement.isLocked)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                achievement.icon,
                                color: achievement.isLocked
                                    ? Colors.grey
                                    : achievement.color,
                                size: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      achievement.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: achievement.isLocked
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (achievement.isLocked)
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MountainPathPainter extends CustomPainter {
  final double progress;

  MountainPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    
    // 绘制更平缓的路径
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.7,
      size.width * 0.4,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.6,
      size.width * 0.8,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.2,
      size.width,
      size.height * 0.25,
    );

    // 绘制虚线路径
    final dashPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 3.0;
    double distance = 0.0;
    
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    // 绘制进度路径
    final progressPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      progressPath.addPath(
        pathMetric.extractPath(0, pathMetric.length * progress),
        Offset.zero,
      );
    }

    // 绘制虚线背景
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 绘制已完成的路径
    canvas.drawPath(progressPath, paint);

    // 绘制路径上的标记点
    if (progress > 0) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        final tangent = pathMetric.getTangentForOffset(
          pathMetric.length * progress,
        );
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MountainSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // 绘制更平缓的山脉
    path.lineTo(size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.4, size.height);
    path.close();

    path.moveTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height);
    path.close();

    path.moveTo(size.width * 0.6, size.height);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 添加长城风格的绘制器
class GreatWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // 绘制长城风格的城墙
    path.lineTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GreatWallPathPainter extends CustomPainter {
  final double progress;

  GreatWallPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    
    // 绘制长城风格的路径
    path.lineTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.8);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.lineTo(size.width * 0.9, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.85);

    // 绘制虚线路径
    final dashPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 3.0;
    double distance = 0.0;
    
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    // 绘制进度路径
    final progressPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      progressPath.addPath(
        pathMetric.extractPath(0, pathMetric.length * progress),
        Offset.zero,
      );
    }

    // 绘制虚线背景
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 绘制已完成的路径
    canvas.drawPath(progressPath, paint);

    // 绘制路径上的标记点
    if (progress > 0) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        final tangent = pathMetric.getTangentForOffset(
          pathMetric.length * progress,
        );
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 添加喜马拉雅风格的绘制器
class HimalayaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // 绘制喜马拉雅风格的山脉
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HimalayaPathPainter extends CustomPainter {
  final double progress;

  HimalayaPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    
    // 绘制喜马拉雅风格的路径
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
    );

    // 绘制虚线路径
    final dashPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 3.0;
    double distance = 0.0;
    
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    // 绘制进度路径
    final progressPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      progressPath.addPath(
        pathMetric.extractPath(0, pathMetric.length * progress),
        Offset.zero,
      );
    }

    // 绘制虚线背景
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 绘制已完成的路径
    canvas.drawPath(progressPath, paint);

    // 绘制路径上的标记点
    if (progress > 0) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        final tangent = pathMetric.getTangentForOffset(
          pathMetric.length * progress,
        );
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 添加金字塔风格的绘制器
class PyramidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // 绘制金字塔风格的山脉
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PyramidPathPainter extends CustomPainter {
  final double progress;

  PyramidPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    
    // 绘制金字塔风格的路径
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.85);

    // 绘制虚线路径
    final dashPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 3.0;
    double distance = 0.0;
    
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    // 绘制进度路径
    final progressPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      progressPath.addPath(
        pathMetric.extractPath(0, pathMetric.length * progress),
        Offset.zero,
      );
    }

    // 绘制虚线背景
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 绘制已完成的路径
    canvas.drawPath(progressPath, paint);

    // 绘制路径上的标记点
    if (progress > 0) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        final tangent = pathMetric.getTangentForOffset(
          pathMetric.length * progress,
        );
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}