import 'package:flutter/material.dart';
import '../widgets/app_footer.dart';

class SettingsUserInfoScreen extends StatelessWidget {
  const SettingsUserInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=User&background=random',
                      ),
                    ),
                    title: const Text('用户名'),
                    subtitle: const Text('用户名称'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('邮箱', style: TextStyle(fontSize: 16)),
                          Text('muststudent@outlook.com', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                      Divider(color: Colors.grey[300], thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('电话', style: TextStyle(fontSize: 16)),
                          Text('未绑定', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('退出登录', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
} 