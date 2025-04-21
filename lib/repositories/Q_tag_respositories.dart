import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QtagRepository {
  Future<void> createQtagItem(int id, String tag) async {
    final Qtag = ParseObject('Q_tags')
     ..set('q_id', id)
     ..set('q_tags', tag);
  }
  Future<List<ParseObject>?> fetchQtag() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Q_tags'));
    final response = await query.query();
    if (response.success && response.results!= null) {
      return response.results as List<ParseObject>;
    } else {
      return null;
    }
  }
}
