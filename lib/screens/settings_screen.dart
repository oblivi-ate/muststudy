import 'package:flutter/material.dart';
import 'settings_userinfo.dart';
import 'settings_account_security.dart';
import 'settings_language.dart';
import 'settings_learning.dart';
import 'settings_help.dart';
import 'settings_contact.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildListTile(context, '个人资料', Icons.person, 'settings_userinfo'),
          _buildListTile(context, '账号与安全', Icons.security, 'settings_account_security'),
          _buildListTile(context, '语言设置', Icons.language, 'settings_language'),
          _buildListTile(context, '学习设置', Icons.school, 'settings_learning'),
          _buildListTile(context, '使用帮助', Icons.help, 'settings_help'),
          _buildListTile(context, '联系', Icons.contact_mail, 'settings_contact'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 16),
            SizedBox(width: 4),
            Text('muststudy 1.0'),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(BuildContext context, String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, routeName),
    );
  }
} 