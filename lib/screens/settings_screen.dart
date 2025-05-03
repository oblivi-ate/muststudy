import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_userinfo.dart';
import 'settings_language.dart';
import 'settings_learning.dart';
import 'settings_help.dart';
import 'settings_contact.dart';
import '../routes/app_router.dart';
import '../widgets/app_footer.dart';

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
                _buildListTile(context, '账户与安全', FontAwesomeIcons.user, Colors.blue, 'settings_userinfo'),
                _buildListTile(context, '学习设置', FontAwesomeIcons.book, Colors.green, 'settings_learning'),
                _buildListTile(context, '语言设置', FontAwesomeIcons.language, Colors.orange, 'settings_language'),
                _buildListTile(context, '使用帮助', FontAwesomeIcons.questionCircle, Colors.green, 'settings_help'),
                _buildListTile(context, '好评鼓励', FontAwesomeIcons.heart, Colors.red, RouteNames.feedback),
                _buildListTile(context, '联系', FontAwesomeIcons.commentDots, Colors.green, 'settings_contact'),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  ListTile _buildListTile(BuildContext context, String title, IconData icon, Color color, String routeName) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () => Navigator.pushNamed(context, routeName),
    );
  }
} 