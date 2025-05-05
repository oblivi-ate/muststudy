import 'package:flutter/material.dart';
import '../screens/pomodoro_timer_screen.dart';
import '../services/pomodoro_service.dart';
import 'package:provider/provider.dart';

class PomodoroTimerIcon extends StatelessWidget {
  const PomodoroTimerIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pomodoroService = Provider.of<PomodoroService>(context);
    
    return GestureDetector(
      onTap: () {
        if (pomodoroService.isActive) {
          print("跳转到番茄钟页面: ${pomodoroService.hours}小时 ${pomodoroService.minutes}分钟");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PomodoroTimerScreen(
                hours: pomodoroService.hours,
                minutes: pomodoroService.minutes,
                userId: pomodoroService.userId,
              ),
            ),
          );
        } else {
          print("跳转到我的页面");
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: pomodoroService.isActive ? Colors.red[400] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 16,
              color: pomodoroService.isActive ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              pomodoroService.isActive ? '番茄钟' : '开始专注',
              style: TextStyle(
                color: pomodoroService.isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 