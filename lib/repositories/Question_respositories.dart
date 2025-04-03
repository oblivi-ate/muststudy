import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
class QuestionRepository {
  Future<void> createQuestionItem(int qid, int pid, String , String qinformation, int like, String qdescription, String qtype) async {
    final question = ParseObject('Question')
      ..set('q_id', qid)
      ..set('p_id', pid)
      ..set('q_information', qinformation)
      ..set('like', like)
      ..set('q_description', qdescription)
      ..set('q_type', qtype);
  }

  Future<List<ParseObject>?> fetchQuestion() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Question'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return null;
  }
}