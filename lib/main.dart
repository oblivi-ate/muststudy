import 'package:flutter/material.dart';
import 'routes/app.dart';
import 'repositories/Question_respositories.dart';
import 'repositories/Answer_respositories.dart';
import 'repositories/Userinfo_respositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化App
  await App.initialize();
  
  // 获取SharedPreferences实例
  final prefs = await SharedPreferences.getInstance();
  
  // 初始化用户数据存储
  final userRepo = UserinfoRepository();
  await userRepo.ensureInitialized();
  print('用户数据存储系统初始化成功');
  
  // 检查是否是首次启动
  bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
  
  if (isFirstLaunch) {
    // 仅在首次启动时初始化默认数据
    print('首次启动应用，初始化默认数据');
  
  // 初始化本地数据
  final questionRepo = QuestionRepository();
  final answerRepo = AnswerRespositories();
  
  await questionRepo.initializeDefaultQuestions();
  await answerRepo.initializeDefaultAnswers();
    
    // 标记已完成首次启动
    await prefs.setBool('is_first_launch', false);
  } else {
    print('非首次启动，保留用户数据');
  }
  
  runApp(const App());
}
