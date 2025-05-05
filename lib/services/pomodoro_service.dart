import 'package:flutter/material.dart';
import 'dart:async';

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
    if (_totalSeconds == 0) {
      _totalSeconds = 10; // 10秒模式
    }
    _remainingSeconds = _totalSeconds;
    _isActive = true;
    _startTime = DateTime.now();
    _lastPauseTime = null;
    
    // 开始计时
    _startTimer();
    
    print("番茄钟启动 - 总时长: $_totalSeconds秒");
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive) {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _completeTimer();
        }
        notifyListeners();
      }
    });
    print("番茄钟计时器启动");
  }
  
  void _completeTimer() {
    _timer?.cancel();
    _isActive = false;
    print("番茄钟完成");
    notifyListeners();
  }
  
  void stopPomodoro() {
    _timer?.cancel();
    _isActive = false;
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
    notifyListeners();
  }
} 