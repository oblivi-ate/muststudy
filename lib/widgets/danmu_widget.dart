import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class DanmuWidget extends StatefulWidget {
  final List<Rect> safeAreas; // 添加安全区域参数
  final double topPadding; // 顶部安全区域
  final double bottomPadding; // 底部安全区域

  const DanmuWidget({
    Key? key,
    this.safeAreas = const [],
    this.topPadding = 0,
    this.bottomPadding = 0,
  }) : super(key: key);

  @override
  State<DanmuWidget> createState() => _DanmuWidgetState();
}

class _DanmuWidgetState extends State<DanmuWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _messages = [
    '加油！你是最棒的！',
    '学习使我快乐~',
    '今天也要元气满满！',
    '坚持就是胜利！',
    '相信自己，你可以的！',
    '每天进步一点点~',
    '学习使我快乐！',
    '一起加油吧！',
    '学软件工程这辈子有了',
    '澳门科技大学我们喜欢你',
  ];
  
  final List<String> _avatars = [
    '🐰', '🐼', '🐨', '🦊', '🐯', '🦁', '🐸', '🐱', '🐶', '🦄'
  ];
  
  final List<DanmuItem> _danmuItems = [];
  final math.Random _random = math.Random();
  final List<double> _occupiedYPositions = []; // 记录当前被占用的Y坐标
  static const double _minSpacing = 50.0; // 弹幕之间的最小间距
  static const double _danmuHeight = 40.0; // 弹幕高度
  static const double _minSpeed = 0.5; // 最小速度
  static const double _maxSpeed = 1.5; // 最大速度
  Timer? _danmuTimer; // 用于控制弹幕生成

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _startDanmuGeneration();
  }

  void _startDanmuGeneration() {
    // 每2-4秒生成一条新弹幕
    _danmuTimer = Timer.periodic(
      Duration(seconds: 2 + _random.nextInt(3)),
      (timer) {
        if (mounted) {
          setState(() {
            _addNewDanmu();
          });
        }
      },
    );
  }

  void _addNewDanmu() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    double yPosition = _findAvailableYPosition(screenHeight);
    
    if (yPosition != -1) {
      _occupiedYPositions.add(yPosition);
      
      // 随机生成速度
      double speed = _minSpeed + _random.nextDouble() * (_maxSpeed - _minSpeed);
      
      _danmuItems.add(DanmuItem(
        message: _messages[_random.nextInt(_messages.length)],
        avatar: _avatars[_random.nextInt(_avatars.length)],
        top: yPosition,
        color: _getRandomColor(),
        startTime: DateTime.now(),
        speed: speed,
        opacity: 0.0,
      ));

      // 添加渐入动画
      Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _danmuItems.last.opacity = 1.0;
          });
        }
      });

      // 移除过期的弹幕
      final now = DateTime.now();
      _danmuItems.removeWhere((item) {
        if (now.difference(item.startTime).inSeconds > 10) {
          _occupiedYPositions.remove(item.top);
          return true;
        }
        return false;
      });
    }
  }

  double _findAvailableYPosition(double screenHeight) {
    // 将屏幕分成多个轨道，考虑安全区域
    final int tracks = ((screenHeight - widget.topPadding - widget.bottomPadding) / _minSpacing).floor();
    final List<double> availablePositions = [];
    
    // 生成所有可能的轨道位置
    for (int i = 0; i < tracks; i++) {
      availablePositions.add(widget.topPadding + i * _minSpacing);
    }
    
    // 找出未被占用的位置
    for (double position in availablePositions) {
      // 检查是否在安全区域内
      bool isInSafeArea = widget.safeAreas.any((safeArea) =>
        position >= safeArea.top && position <= safeArea.bottom
      );
      
      if (isInSafeArea) continue;
      
      bool isOccupied = _occupiedYPositions.any((occupied) => 
        (position - occupied).abs() < _minSpacing
      );
      
      if (!isOccupied) {
        return position;
      }
    }
    
    return -1; // 没有找到可用位置
  }

  Color _getRandomColor() {
    return Color.fromRGBO(
      _random.nextInt(200) + 55,
      _random.nextInt(200) + 55,
      _random.nextInt(200) + 55,
      0.9,
    );
  }

  @override
  void dispose() {
    _danmuTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: _danmuItems.map((item) {
          return Positioned(
            right: 0,
            top: item.top,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: item.opacity,
                  child: Transform.translate(
                    offset: Offset(
                      -_controller.value * (screenWidth + 200) * item.speed, // 使用不同的速度
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            item.avatar,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.message,
                            style: TextStyle(
                              color: item.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.6),
                                  offset: const Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DanmuItem {
  final String message;
  final String avatar;
  final double top;
  final Color color;
  final DateTime startTime;
  double opacity;
  final double speed; // 添加速度属性

  DanmuItem({
    required this.message,
    required this.avatar,
    required this.top,
    required this.color,
    required this.startTime,
    required this.speed, // 添加速度参数
    this.opacity = 1.0,
  });
} 