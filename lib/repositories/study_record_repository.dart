import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/study_record.dart';

class StudyRecordRepository {
  static const String _localRecordsKey = 'local_study_records';
  
  /// 添加一条学习记录（远程和本地同时保存）
  Future<bool> addStudyRecord(int userId, StudyRecord record) async {
    try {
      // 远程保存
    final object = ParseObject('StudyRecord')
      ..set('userId', userId)
      ..set('date', record.date.toIso8601String())
        ..set('duration', record.duration)
        ..set('type', record.type)
        ..set('description', record.description)
        ..set('status', record.status)
        ..set('hours', record.hours);
        
      // 尝试远程保存，但不等待结果
      object.save().then((response) {
    if (!response.success) {
          print('远程保存学习记录失败: ${response.error?.message}');
        }
      });
      
      // 本地保存（确保即使离线也能工作）
      return await _saveRecordLocally(userId, record);
    } catch (e) {
      print('保存学习记录失败: $e');
      // 尝试仅本地保存
      return await _saveRecordLocally(userId, record);
    }
  }
  
  /// 本地保存学习记录
  Future<bool> _saveRecordLocally(int userId, StudyRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_localRecordsKey}_$userId';
      
      // 读取现有记录
      List<Map<String, dynamic>> records = [];
      final storedRecords = prefs.getString(key);
      
      if (storedRecords != null) {
        records = List<Map<String, dynamic>>.from(jsonDecode(storedRecords));
      }
      
      // 添加新记录
      records.add(record.toMap());
      
      // 保存回本地存储
      await prefs.setString(key, jsonEncode(records));
      print('本地保存学习记录成功: ${record.date} ${record.type} ${record.hours}小时');
      return true;
    } catch (e) {
      print('本地保存学习记录失败: $e');
      return false;
    }
  }

  /// 获取用户的所有学习记录（优先从本地获取，失败时尝试远程）
  Future<List<StudyRecord>> getStudyRecords(int userId) async {
    try {
      // 先尝试获取本地记录
      final localRecords = await _getLocalRecords(userId);
      if (localRecords.isNotEmpty) {
        return localRecords;
      }
      
      // 如果本地没有，尝试从远程获取
    final query = QueryBuilder<ParseObject>(ParseObject('StudyRecord'))
      ..whereEqualTo('userId', userId)
        ..orderByDescending('date'); // 按日期降序排列，最新的在前面
        
    final response = await query.query();
    if (response.success && response.results != null) {
        final records = (response.results as List<ParseObject>).map((obj) {
        final dateStr = obj.get<String>('date') ?? '';
        final duration = obj.get<int>('duration') ?? 0;
          final type = obj.get<String>('type') ?? '番茄钟';
          final description = obj.get<String>('description') ?? '';
          final status = obj.get<String>('status') ?? '完成';
          final hours = obj.get<double>('hours') ?? 0.0;
          
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
          
          return StudyRecord(
            date: date, 
            duration: duration,
            type: type,
            description: description,
            status: status,
            hours: hours,
          );
      }).toList();
        
        // 保存到本地缓存
        await _saveRecordsLocally(userId, records);
        
        return records;
      }
      return [];
    } catch (e) {
      print('获取学习记录失败: $e');
      return await _getLocalRecords(userId);
    }
  }
  
  /// 从本地获取学习记录
  Future<List<StudyRecord>> _getLocalRecords(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_localRecordsKey}_$userId';
      final storedRecords = prefs.getString(key);
      
      if (storedRecords != null) {
        final recordsList = List<Map<String, dynamic>>.from(jsonDecode(storedRecords));
        return recordsList.map((map) => StudyRecord.fromMap(map)).toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // 按日期降序排列
      }
      return [];
    } catch (e) {
      print('从本地获取学习记录失败: $e');
    return [];
    }
  }
  
  /// 保存记录列表到本地
  Future<bool> _saveRecordsLocally(int userId, List<StudyRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_localRecordsKey}_$userId';
      
      final recordMaps = records.map((r) => r.toMap()).toList();
      await prefs.setString(key, jsonEncode(recordMaps));
      
      return true;
    } catch (e) {
      print('保存记录列表到本地失败: $e');
      return false;
    }
  }
  
  /// 添加番茄钟记录的便捷方法
  Future<bool> addPomodoroRecord(int userId, DateTime date, int durationSeconds, double hours, String status) async {
    final record = StudyRecord(
      date: date,
      duration: durationSeconds,
      type: '番茄钟',
      description: '完成${(hours * 60).round()}分钟的学习',
      status: status,
      hours: hours,
    );
    
    return await addStudyRecord(userId, record);
  }
} 