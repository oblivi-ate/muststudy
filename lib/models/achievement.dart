import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String title;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final int currentProgress;
  final int totalGoal;
  final String description;
  final List<Milestone> milestones;

  Achievement({
    required this.title,
    required this.icon,
    required this.color,
    this.isLocked = true,
    this.currentProgress = 0,
    required this.totalGoal,
    required this.description,
    required this.milestones,
  });

  double get progressPercentage => currentProgress / totalGoal;

  static Achievement fromParseObject(ParseObject parseObject) {
    return Achievement(
      title: parseObject.get<String>('title') ?? '',
      icon: Icons.star,
      color: Colors.blue,
      isLocked: parseObject.get<bool>('isLocked') ?? true,
      currentProgress: parseObject.get<int>('progress') ?? 0,
      totalGoal: parseObject.get<int>('goal') ?? 100,
      description: parseObject.get<String>('description') ?? '',
      milestones: [],
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isLocked: json['isLocked'],
      currentProgress: json['currentProgress'],
      totalGoal: json['totalGoal'],
      description: json['description'],
      milestones: List<Milestone>.from(json['milestones'].map((x) => Milestone.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'color': color.value,
      'isLocked': isLocked,
      'currentProgress': currentProgress,
      'totalGoal': totalGoal,
      'description': description,
      'milestones': milestones.map((x) => x.toJson()).toList(),
    };
  }
}

class Milestone {
  final String name;
  final String requirement;
  final int requiredProgress;

  Milestone({
    required this.name,
    required this.requirement,
    required this.requiredProgress,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      name: json['name'],
      requirement: json['requirement'],
      requiredProgress: json['requiredProgress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'requirement': requirement,
      'requiredProgress': requiredProgress,
    };
  }
}

class AchievementManager {
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  Achievement? _currentAchievement;
  List<Achievement> achievements = [
    Achievement(
      title: '喜马拉雅收藏家',
      icon: Icons.landscape,
      color: Colors.blue[700]!,
      isLocked: false,
      currentProgress: 15,
      totalGoal: 30,
      description: '在学习资源中收藏优质内容',
      milestones: [
        Milestone(name: '第一个营地', requirement: '10次收藏', requiredProgress: 10),
        Milestone(name: '第二个营地', requirement: '20次收藏', requiredProgress: 20),
        Milestone(name: '山顶', requirement: '30次收藏', requiredProgress: 30),
      ],
    ),
    Achievement(
      title: '长城探险家',
      icon: Icons.landscape,
      color: Colors.blue[700]!,
      isLocked: false,
      currentProgress: 5,
      totalGoal: 20,
      description: '完成中国历史相关的学习任务',
      milestones: [
        Milestone(name: '烽火台', requirement: '完成5个任务', requiredProgress: 5),
        Milestone(name: '敌楼', requirement: '完成10个任务', requiredProgress: 10),
        Milestone(name: '将军台', requirement: '完成20个任务', requiredProgress: 20),
      ],
    ),
    Achievement(
      title: '金字塔探险家',
      icon: Icons.account_balance,
      color: Colors.orange[700]!,
      currentProgress: 0,
      totalGoal: 15,
      description: '完成数学相关的学习任务',
      milestones: [
        Milestone(name: '第一层', requirement: '完成5个任务', requiredProgress: 5),
        Milestone(name: '中层', requirement: '完成10个任务', requiredProgress: 10),
        Milestone(name: '金字塔尖', requirement: '完成15个任务', requiredProgress: 15),
      ],
    ),
    // ... 其他成就
  ];

  Achievement? get currentAchievement => _currentAchievement ?? achievements[0];

  void setCurrentAchievement(Achievement achievement) {
    _currentAchievement = achievement;
  }
  
  // 从SharedPreferences加载喜马拉雅收藏家成就进度
  Future<void> loadHimalayaCollectorProgress(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final himalayaAchievementId = 'himalaya_collector';
      final achievementKey = 'achievement_${himalayaAchievementId}_$userId';
      final progress = prefs.getInt(achievementKey) ?? 0;
      
      // 更新喜马拉雅收藏家成就进度
      for (int i = 0; i < achievements.length; i++) {
        if (achievements[i].title == '喜马拉雅收藏家') {
          achievements[i] = Achievement(
            title: achievements[i].title,
            icon: achievements[i].icon,
            color: achievements[i].color,
            isLocked: achievements[i].isLocked,
            currentProgress: progress,  // 更新为从SharedPreferences读取的值
            totalGoal: achievements[i].totalGoal,
            description: achievements[i].description,
            milestones: achievements[i].milestones,
          );
          
          // 如果当前选中的就是喜马拉雅收藏家成就，更新当前选中的成就
          if (_currentAchievement != null && _currentAchievement!.title == '喜马拉雅收藏家') {
            _currentAchievement = achievements[i];
          }
          
          break;
        }
      }
    } catch (e) {
      print('加载喜马拉雅收藏家成就进度失败: $e');
    }
  }
} 