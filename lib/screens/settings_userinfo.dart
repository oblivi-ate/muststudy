import 'package:flutter/material.dart';

class SettingsUserInfoScreen extends StatelessWidget {
  const SettingsUserInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
      ),
      body: const Center(
        child: Text('个人资料页面'),
      ),
    );
  }
} 