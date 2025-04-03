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
}