import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUsername') ?? '未登录';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: FutureBuilder<String>(
        future: _getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final username = snapshot.data ?? '未登录';
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=$username&background=random',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('更改密码'),
                onTap: () {
                  // TODO: Implement change password
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('通知设置'),
                onTap: () {
                  // TODO: Implement notification settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('语言设置'),
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
            ],
          );
        },
      ),
    );
  }
} 