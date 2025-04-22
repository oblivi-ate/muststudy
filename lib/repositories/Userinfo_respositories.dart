import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserinfoRepository {
  Future<void> createUserinfoItem(int id, String name, String password) async {
    final userinfo = ParseObject('Userinfo')
      ..set('u_id', id)
      ..set('u_name', name)
      ..set('u_password', password);
    final response = await userinfo.save();
    if (response.success) {
      print('Userinfo item created successfully');
    } else {
      print('Failed to create Userinfo item: ${response.error?.message}');
    }
  }

  Future<List<ParseObject>?> fetchUserinfo() async {
    try {
      print('开始获取用户信息...');
      final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'));
      print('查询对象已创建');
      final response = await query.query();
      print('查询执行完成，状态：${response.success}');
      print('错误信息：${response.error?.message ?? "无"}');
      print('结果数量：${response.results?.length ?? 0}');
      
      if (response.success && response.results != null) {
        return response.results as List<ParseObject>;
      }
      print('获取失败：${response.error?.message}');
      return null;
    } catch (e) {
      print('获取用户信息时发生错误: $e');
      return null;
    }
  }

  Future<void> updateUserinfo(int id, String newName, String newPassword) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
      ..whereEqualTo('u_id', id);
    final response = await query.query();
    if (response.success && response.results != null) {
      final user = response.results!.first as ParseObject;
      user
        ..set('u_name', newName)
        ..set('u_password', newPassword);
      await user.save();
    }
  }

  Future<void> deleteUserinfo(int id) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
      ..whereEqualTo('u_id', id);
    final response = await query.query();
    if (response.success && response.results != null) {
      final user = response.results!.first as ParseObject;
      await user.delete();
    }
  }

  Future<String> getUserName(int userId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'))
      ..whereEqualTo('u_id', userId);
    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      final user = response.results!.first as ParseObject;
      return user.get<String>('u_name') ?? 'Unknown';
    }
    return 'Unknown';
  }
}