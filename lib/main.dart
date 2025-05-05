import 'package:flutter/material.dart';
import 'routes/app.dart';
import 'repositories/Question_respositories.dart';
import 'repositories/Answer_respositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化App
  await App.initialize();
  
  // 清除旧的缓存数据
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // 初始化本地数据
  final questionRepo = QuestionRepository();
  final answerRepo = AnswerRespositories();
  
  await questionRepo.initializeDefaultQuestions();
  await answerRepo.initializeDefaultAnswers();
  
  runApp(const App());
}
