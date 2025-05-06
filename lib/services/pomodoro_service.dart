import 'package:flutter/material.dart';
import 'dart:async';
import '../repositories/Userinfo_respositories.dart';
import '../repositories/study_record_repository.dart';

class PomodoroService extends ChangeNotifier {
  static final PomodoroService _instance = PomodoroService._internal();
  
  factory PomodoroService() {
    return _instance;
  }
  
  PomodoroService._internal();
  
  bool _isActive = false;
  int _hours = 0;
  int _minutes = 0;
  int _userId = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  DateTime? _startTime;
  DateTime? _lastPauseTime;
  final UserinfoRepository _userinfoRepository = UserinfoRepository();
  final StudyRecordRepository _studyRecordRepository = StudyRecordRepository();
  
  bool get isActive => _isActive;
  int get hours => _hours;
  int get minutes => _minutes;
  int get userId => _userId;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  
  void startPomodoro(int hours, int minutes, int userId) {
    _hours = hours;
    _minutes = minutes;
    _userId = userId;
    _totalSeconds = hours * 3600 + minutes * 60;
    
    // 处理特殊的短时间模式
    if (_totalSeconds == 0) {
      // 如果总时间为0，则默认使用30秒作为计时时间
      _totalSeconds = 30; // 30秒模式
      print("启动短时间番茄钟 - 30秒模式 - 总时长: $_totalSeconds秒");
    } else {
      print("番茄钟启动 - 总时长: $_totalSeconds秒");
    }
    
    _remainingSeconds = _totalSeconds;
    _isActive = true;
    _startTime = DateTime.now();
    _lastPauseTime = null;
    
    // 开始计时
    _startTimer();
    
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive) {
        _remainingSeconds--;
        // 添加剩余时间日志，便于调试
        if (_totalSeconds <= 30) {
          // 对于30秒模式，每秒都打印日志
          print("番茄钟计时中: 剩余 $_remainingSeconds 秒");
        } else if (_remainingSeconds % 5 == 0 || _remainingSeconds < 5) {
          print("番茄钟计时中: 剩余 $_remainingSeconds 秒");
        }
        
        if (_remainingSeconds <= 0) {
          _completeTimer();
        }
        notifyListeners();
      }
    });
    print("番茄钟计时器启动，总时长: $_totalSeconds 秒");
  }
  
  void _completeTimer() {
    _timer?.cancel();
    _isActive = false;
    print("番茄钟完成");
    
    // 计算并更新学习时长
    final studyHours = _totalSeconds / 3600;
    
    // 检查是否是短时间模式（30秒），确保记录正确的学习时间
    if (_totalSeconds == 30) {
      print("短时间模式（30秒）完成，记录学习时间: $studyHours 小时");
    }
    
    // 更新用户信息统计中的学习时长
    _userinfoRepository.updateStudyHours(_userId, studyHours).then((success) {
      if (success) {
        print("计时完成，成功更新学习时长: $studyHours 小时");
        
        // 添加学习记录
        final endTime = DateTime.now();
        final actualSeconds = _startTime != null
            ? endTime.difference(_startTime!).inSeconds
            : _totalSeconds;
            
        _studyRecordRepository.addPomodoroRecord(
          _userId,
          endTime,
          actualSeconds,
          studyHours,
          '完成'
        ).then((recordSuccess) {
          if (recordSuccess) {
            print("学习记录添加成功");
          } else {
            print("学习记录添加失败");
          }
        });
        
      } else {
        print("计时完成，但更新学习时长失败");
      }
    }).catchError((error) {
      print("更新学习时长时发生错误: $error");
    });
    
    notifyListeners();
  }
  
  void stopPomodoro() {
    if (_isActive) {
    _timer?.cancel();
    _isActive = false;
      
      // 计算已学习的时间（秒）和小时
      final endTime = DateTime.now();
      final actualSeconds = _startTime != null 
          ? endTime.difference(_startTime!).inSeconds 
          : _totalSeconds - _remainingSeconds;
      final studyHours = actualSeconds / 3600;
      
      // 只有当实际学习了一段时间时才记录
      if (actualSeconds > 0) {
        // 添加学习记录（标记为"中断"）
        _studyRecordRepository.addPomodoroRecord(
          _userId,
          endTime,
          actualSeconds,
          studyHours,
          '中断'
        );
      }
    }
    
    _remainingSeconds = 0;
    notifyListeners();
  }
  
  void resumePomodoro() {
    if (!_isActive && _remainingSeconds > 0) {
      _isActive = true;
      if (_lastPauseTime != null) {
        final now = DateTime.now();
        final elapsedSeconds = now.difference(_lastPauseTime!).inSeconds;
        _remainingSeconds = _remainingSeconds - elapsedSeconds;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _completeTimer();
          return;
        }
      }
      _startTimer();
      notifyListeners();
    }
  }
  
  void pausePomodoro() {
    if (_isActive) {
      _isActive = false;
      _lastPauseTime = DateTime.now();
      _timer?.cancel();
      notifyListeners();
    }
  }
  
  void resetPomodoro() {
    _timer?.cancel();
    _isActive = false;
    _remainingSeconds = _totalSeconds;
    _lastPauseTime = null;
    _startTime = DateTime.now(); // 重置开始时间
    notifyListeners();
  }
} 