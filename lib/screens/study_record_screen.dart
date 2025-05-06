import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_record.dart';
import '../repositories/study_record_repository.dart';
import 'package:intl/intl.dart';

enum Period { day, week, month, year }

class StudyRecordScreen extends StatefulWidget {
  const StudyRecordScreen({Key? key}) : super(key: key);

  @override
  State<StudyRecordScreen> createState() => _StudyRecordScreenState();
}

class _StudyRecordScreenState extends State<StudyRecordScreen> {
  final StudyRecordRepository _repo = StudyRecordRepository();
  List<StudyRecord> _records = [];
  Period _selectedPeriod = Period.day;
  int _userId = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRecords();
  }

  Future<void> _loadUserIdAndRecords() async {
    final prefs = await SharedPreferences.getInstance();
    // 从缓存用户信息中读取 userId
    final cached = prefs.getString('cached_user_info');
    if (cached != null) {
      try {
        final data = Map<String, dynamic>.from(await Future.value(jsonDecode(cached)));
        _userId = data['userId'] ?? 0;
      } catch (_) {}
    }
    
    // 尝试从SharedPreferences直接获取用户ID
    if (_userId == 0) {
      _userId = prefs.getInt('current_user_id') ?? 1;
    }
    
    if (_userId > 0) {
      // 设置超时
      final timeout = Future.delayed(const Duration(milliseconds: 300));
      
      try {
      final list = await Future.any([
        _repo.getStudyRecords(_userId),
        timeout,
      ]);
      
        if (mounted) {
      setState(() {
            _records = list is List<StudyRecord> ? list : [];
        _loading = false;
      });
        }
      } catch (e) {
        print('加载学习记录失败: $e');
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } else {
      if (mounted) {
      setState(() => _loading = false);
      }
    }
  }

  // 过滤选定时期的记录
  List<StudyRecord> _getFilteredRecords() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case Period.day:
        return _records.where((r) => 
          r.date.year == now.year && 
          r.date.month == now.month && 
          r.date.day == now.day
        ).toList();
        
      case Period.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return _records.where((r) => r.date.isAfter(startDate) || r.date.isAtSameMomentAs(startDate)).toList();
        
      case Period.month:
        return _records.where((r) => 
          r.date.year == now.year && 
          r.date.month == now.month
        ).toList();
        
      case Period.year:
        return _records.where((r) => r.date.year == now.year).toList();
        
      default:
        return _records;
    }
  }

  Map<DateTime, int> _aggregateByDate() {
    final map = <DateTime, int>{};
    final filteredRecords = _getFilteredRecords();
    
    for (var r in filteredRecords) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      map[day] = (map[day] ?? 0) + r.duration;
    }
    return map;
  }

  List<MapEntry<DateTime, int>> _entriesForPeriod() {
    final byDate = _aggregateByDate().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return byDate;
  }

  /// 绘制最近20周的热力图
  Widget _buildHeatMap() {
    // 聚合每天的学习时长（小时）而不是秒数
    final aggregatedData = <DateTime, double>{};
    final filteredRecords = _getFilteredRecords();
    
    // 按天聚合学习时长
    for (var record in filteredRecords) {
      final day = DateTime(record.date.year, record.date.month, record.date.day);
      aggregatedData[day] = (aggregatedData[day] ?? 0) + record.hours;
    }
    
    // 获取过去几周的日期范围 (只显示10周)
    final today = DateTime.now();
    // 计算今天是星期几 (1-7, 周一到周日)
    final dayOfWeek = today.weekday;
    // 计算本周的周一
    final startOfCurrentWeek = today.subtract(Duration(days: dayOfWeek - 1));
    // 生成从 10 周前到本周的日期范围
    final startDate = startOfCurrentWeek.subtract(const Duration(days: 9 * 7));
    
    // 构建日期列表
    final List<DateTime> days = [];
    for (int i = 0; i < 10 * 7; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    
    final maxVal = aggregatedData.values.isEmpty ? 0.0 : aggregatedData.values.reduce((a, b) => a > b ? a : b);
    
    // 构建星期标签
    final weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    
          return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 月份标签行
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: SizedBox(
                    height: 16,
            child: Row(
              children: [
                // 生成月份标签
                for (int week = 0; week < 10; week++) 
                  _buildMonthLabel(days[week * 7])
              ],
            ),
          ),
        ),
        
        // 热力图主体
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 星期标签列
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 7; i++)
                  Container(
                    width: 24,
                    height: 20,
                    alignment: Alignment.center,
                    child: Text(
                      weekdayLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            
            // 热力图格子
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int week = 0; week < 10; week++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int day = 0; day < 7; day++)
                            _buildHeatMapCell(days[week * 7 + day], aggregatedData, maxVal),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // 颜色图例
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('较少', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const SizedBox(width: 4),
              for (int i = 0; i < 5; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2 + (i * 0.15)),
                    border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
                  ),
                ),
              const SizedBox(width: 4),
              Text('较多', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
              );
  }
  
  // 构建月份标签
  Widget _buildMonthLabel(DateTime date) {
    // 只在月份第一周显示月份名称 (当日是1-7号)
    if (date.day <= 7) {
      return SizedBox(
        width: 20,
        child: Text(
          '${date.month}月',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
          );
    } else {
      return const SizedBox(width: 20);
    }
  }
  
  // 构建热力图单元格
  Widget _buildHeatMapCell(DateTime day, Map<DateTime, double> data, double maxVal) {
    final key = DateTime(day.year, day.month, day.day);
    final val = data[key] ?? 0.0;
    
    // 划分不同的颜色深度等级
    Color cellColor;
    if (val <= 0) {
      cellColor = Colors.grey[200]!;
    } else {
      // 根据学习时长划分5个等级
      double intensity;
      if (maxVal > 0) {
        intensity = val / maxVal;
      } else {
        intensity = 0;
      }
      
      if (intensity < 0.2) {
        cellColor = const Color(0xFFB3E5B5); // 最浅的绿色
      } else if (intensity < 0.4) {
        cellColor = const Color(0xFF8FD094);
      } else if (intensity < 0.6) {
        cellColor = const Color(0xFF6EBB74);
      } else if (intensity < 0.8) {
        cellColor = const Color(0xFF4CA652);
      } else {
        cellColor = const Color(0xFF338A37); // 最深的绿色
      }
    }
    
    // 格式化日期和时长显示
    final dateFormatter = DateFormat('yyyy年MM月dd日');
    final formattedDate = dateFormatter.format(day);
    final hoursText = val > 0 
        ? '${val.toStringAsFixed(1)}小时'
        : '无学习记录';
    
    // 判断是否是今天
    final now = DateTime.now();
    final isToday = day.year == now.year && 
                   day.month == now.month && 
                   day.day == now.day;
    
    return Container(
      margin: const EdgeInsets.all(2),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: isToday 
            ? Border.all(color: Colors.blue, width: 1.5)
            : null,
      ),
      child: Tooltip(
        message: '$formattedDate: $hoursText',
        child: const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadUserIdAndRecords();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 自定义周期选择栏
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: Period.values.map((p) {
                        final isSelected = p == _selectedPeriod;
                        final label = {
                          Period.day: '日',
                          Period.week: '周',
                          Period.month: '月',
                          Period.year: '年',
                        }[p]!;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = p),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              height: 28,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 热力图卡片
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // 热力图标题与帮助图标
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                              const Text('学习热力图', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('热力图说明'),
                                      content: const Text('热力图展示每日学习时长统计，颜色深浅表示学习时长多少，蓝色边框表示今天。'),
                              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('我知道了'))],
                            ),
                          );
                        },
                        child: const Icon(Icons.help_outline, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                          _buildHeatMap(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 标题与统计信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_periodToString(_selectedPeriod)}学习记录',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '共${filteredRecords.length}条记录',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 番茄钟记录列表
                  Expanded(
                    child: filteredRecords.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  '当前${_periodToString(_selectedPeriod)}还没有学习记录',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) => _buildStudyRecordItem(filteredRecords[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  String _periodToString(Period period) {
    switch (period) {
      case Period.day:
        return '今日';
      case Period.week:
        return '本周';
      case Period.month:
        return '本月';
      case Period.year:
        return '今年';
      default:
        return '';
    }
  }

  // 构建学习记录项
  Widget _buildStudyRecordItem(StudyRecord record) {
    // 计算持续时间显示格式
    final hours = record.duration ~/ 3600;
    final minutes = (record.duration % 3600) ~/ 60;
    final seconds = record.duration % 60;
    final durationText = hours > 0
        ? '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}'
        : minutes > 0
            ? '$minutes分钟${seconds > 0 ? ' $seconds秒' : ''}'
            : '$seconds秒';
    
    // 格式化日期时间
    final dateFormat = DateFormat('MM-dd HH:mm');
    final dateText = dateFormat.format(record.date);
    
    // 状态颜色
    final statusColor = record.status == '完成' ? Colors.green : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.timer,
            color: Colors.red[700],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              '番茄钟学习',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                record.status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text('$dateText · 学习时长 $durationText'),
        trailing: Text(
          '${record.hours.toStringAsFixed(2)}h',
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 自定义条形图，展示每日学习时长柱状 - 移除不用
  Widget _buildBarChart() {
    final entries = _entriesForPeriod();
    final maxVal = entries.fold<int>(0, (prev, e) => e.value > prev ? e.value : prev);
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((e) {
          final factor = maxVal > 0 ? e.value / maxVal : 0.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 200 * factor,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${e.key.month}/${e.key.day}',
                  style: const TextStyle(fontSize: 8),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
} 