import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';
import 'achievement_screen.dart';
import '../widgets/pomodoro_timer_icon.dart';
import '../services/pomodoro_service.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PomodoroService _pomodoroService = PomodoroService();
  bool _showPomodoroIcon = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AchievementScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 监听番茄钟状态变化
    _pomodoroService.addListener(_updatePomodoroStatus);
  }

  @override
  void dispose() {
    // 移除监听
    _pomodoroService.removeListener(_updatePomodoroStatus);
    super.dispose();
  }

  void _updatePomodoroStatus() {
    setState(() {
      _showPomodoroIcon = _pomodoroService.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pomodoroService,
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_currentIndex],
            // 显示番茄钟图标
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: const PomodoroTimerIcon(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, '首页'),
                  _buildNavItem(1, Icons.emoji_events_outlined, Icons.emoji_events, '成就'),
                  _buildNavItem(2, Icons.message_outlined, Icons.message, '消息'),
                  _buildNavItem(3, Icons.person_outline, Icons.person, '我的'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
