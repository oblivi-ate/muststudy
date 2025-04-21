import 'package:flutter/material.dart';

class SettingsAccountSecurityScreen extends StatelessWidget {
  const SettingsAccountSecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号与安全'),
      ),
      body: const Center(
        child: Text('账号与安全页面'),
      ),
    );
  }
} 