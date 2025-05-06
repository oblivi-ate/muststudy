import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repositories/Userinfo_respositories.dart';
import '../services/pomodoro_service.dart';

class PomodoroTimerScreen extends StatefulWidget {
  final int hours;
  final int minutes;
  final int userId;

  const PomodoroTimerScreen({
    Key? key,
    required this.hours,
    required this.minutes,
    required this.userId,
  }) : super(key: key);

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> with WidgetsBindingObserver {
  final UserinfoRepository _userinfoRepository = UserinfoRepository();
  late final PomodoroService _pomodoroService;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 获取单例服务实例
    _pomodoroService = PomodoroService();
    
    // 启动番茄钟(如果未启动)
    if (!_pomodoroService.isActive) {
      if (widget.hours == 0 && widget.minutes == 0) {
        print("启动30秒番茄钟模式");
      } else {
      print("启动番茄钟: ${widget.hours}小时 ${widget.minutes}分钟");
      }
      _pomodoroService.startPomodoro(widget.hours, widget.minutes, widget.userId);
    } else {
      print("番茄钟已启动,剩余时间: ${_pomodoroService.remainingSeconds}秒");
    }
    
    // 添加监听器来更新UI
    _pomodoroService.addListener(_updateTimer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pomodoroService.removeListener(_updateTimer);
    super.dispose();
  }

  void _updateTimer() {
    if (mounted) {
      setState(() {
        // 检查番茄钟是否刚刚完成
        if (_pomodoroService.remainingSeconds == 0 && !_hasRecordedCompletion) {
          _recordCompletion();
        }
      });
    }
  }

  // 添加标志变量，避免重复记录
  bool _hasRecordedCompletion = false;
  
  // 记录番茄钟完成并更新学习时长
  void _recordCompletion() {
    if (_hasRecordedCompletion) return;
    
    _hasRecordedCompletion = true;
    
    // 这里不需要做什么，因为服务已经会自动调用更新学习时长
    print("番茄钟界面检测到计时完成，学习时长已经由服务更新");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 应用进入后台,暂停计时
      _pomodoroService.pausePomodoro();
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台,恢复计时
      _pomodoroService.resumePomodoro();
    }
  }

  void _togglePause() {
    if (_pomodoroService.isActive) {
      _pomodoroService.pausePomodoro();
    } else {
      _pomodoroService.resumePomodoro();
    }
  }

  void _resetTimer() {
    _pomodoroService.resetPomodoro();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 显示返回确认对话框
        bool shouldReturn = await _showExitConfirmationDialog();
        return shouldReturn;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '番茄钟',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black87,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // 显示返回确认对话框
              bool shouldReturn = await _showExitConfirmationDialog();
              if (shouldReturn && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // 添加停止番茄钟按钮
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              color: Colors.red,
              onPressed: () {
                // 显示停止确认对话框
                _showStopConfirmationDialog();
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 圆形进度条和时间
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: _pomodoroService.remainingSeconds / _pomodoroService.totalSeconds,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _pomodoroService.remainingSeconds == 0
                                ? Colors.green
                                : _pomodoroService.isActive
                                    ? Colors.red[400]!
                                    : Colors.orange,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_pomodoroService.remainingSeconds),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pomodoroService.remainingSeconds == 0
                                ? '学习完成!'
                                : _pomodoroService.isActive
                                    ? '专注学习中...'
                                    : '已暂停',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 控制按钮
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_pomodoroService.remainingSeconds > 0) ...[
                      IconButton(
                        onPressed: _togglePause,
                        icon: Icon(
                          _pomodoroService.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          size: 48,
                          color: _pomodoroService.isActive ? Colors.orange : Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                    IconButton(
                      onPressed: _pomodoroService.remainingSeconds == 0 ? null : _resetTimer,
                      icon: Icon(
                        Icons.refresh,
                        size: 48,
                        color: _pomodoroService.remainingSeconds == 0 ? Colors.grey[400] : Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '返回首页',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '已学习时间: ${_formatTime(_pomodoroService.totalSeconds - _pomodoroService.remainingSeconds)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '番茄钟将在后台继续计时\n可随时从顶部图标返回',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  result = false;
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  result = true;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '返回首页',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _showStopConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stop_circle_outlined,
                color: Colors.red[700],
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '停止番茄钟?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '已学习时间: ${_formatTime(_pomodoroService.totalSeconds - _pomodoroService.remainingSeconds)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '停止后将记录已学习的时间',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 计算已学习时长（小时）
                  final studyHours = (_pomodoroService.totalSeconds - _pomodoroService.remainingSeconds) / 3600;
                  
                  // 更新学习时长
                  _userinfoRepository.updateStudyHours(widget.userId, studyHours).then((success) {
                    if (success) {
                      print('成功保存学习时长: $studyHours 小时');
                    } else {
                      print('警告: 学习时长可能未成功保存');
                    }
                  
                  // 停止番茄钟服务
                  _pomodoroService.stopPomodoro();
                  
                  Navigator.pop(context); // 关闭对话框
                  Navigator.pop(context); // 返回上一页
                  }).catchError((error) {
                    print('保存学习时长时出错: $error');
                    // 仍然停止番茄钟并返回
                    _pomodoroService.stopPomodoro();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '停止',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void _startPomodoroTimer() async {
    int selectedHours = 0;
    int selectedMinutes = 0;

    // 显示选择学习时长的对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '选择学习时长',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '小时'),
              onChanged: (value) {
                selectedHours = int.tryParse(value) ?? 0;
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '分钟'),
              onChanged: (value) {
                selectedMinutes = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedHours == 0 && selectedMinutes == 0) {
                // 如果选择了30秒模式
                print("选择了30秒模式");
                selectedMinutes = 0;
                selectedHours = 0;
              }

              // 启动番茄钟
              _pomodoroService.startPomodoro(selectedHours, selectedMinutes, widget.userId);
              
              // 跳转到番茄钟页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PomodoroTimerScreen(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                    userId: widget.userId,
                  ),
                ),
              );
            },
            child: const Text(
              '开始',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 