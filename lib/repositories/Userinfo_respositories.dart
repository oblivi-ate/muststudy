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
    final query = QueryBuilder<ParseObject>(ParseObject('Userinfo'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return null;
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
}