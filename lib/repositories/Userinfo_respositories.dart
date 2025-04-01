import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
class UserinfoRepository {
  Future<void> createUserinfoItem(int id, String name, String password) async {
    final userinfo = ParseObject('Userinfo')
      ..set('id', id)
      ..set('name', name)
      ..set('password', password);
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