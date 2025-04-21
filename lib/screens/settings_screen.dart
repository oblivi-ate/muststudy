import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildListTile(context, '个人资料', Icons.person, 'settings_userinfo'),
                _buildListTile(context, '账号与安全', Icons.security, 'settings_account_security'),
                _buildListTile(context, '语言设置', Icons.language, 'settings_language'),
                _buildListTile(context, '学习设置', Icons.school, 'settings_learning'),
                _buildListTile(context, '使用帮助', Icons.help, 'settings_help'),
                _buildListTile(context, '联系', Icons.contact_mail, 'settings_contact'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 32, color: Colors.grey.withOpacity(0.5)), // 增大图标并调整颜色
                const SizedBox(width: 8),
                Text(
                  'MUSTSTUDY v1.0',
                  style: GoogleFonts.getFont(
                    'Press Start 2P', // 使用可用的像素风格字体
                    fontSize: 12, // 调整字体大小
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic, // 设置为斜体
                    color: Colors.grey.withOpacity(0.5), // 更透明的灰色
                  ),
                ),
              ],
            ),
          ),
        ],
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