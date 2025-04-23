import 'package:flutter/material.dart';

class SettingsContactScreen extends StatelessWidget {
  const SettingsContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系'),
      ),
      body: const Center(
        child: Text('联系页面'),
      ),
    );
  }
} 