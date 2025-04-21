import 'package:flutter/material.dart';

class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用帮助'),
      ),
      body: const Center(
        child: Text('使用帮助页面'),
      ),
    );
  }
} 