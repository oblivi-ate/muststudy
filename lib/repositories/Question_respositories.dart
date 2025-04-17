import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QuestionRepository {
  Future<void> createQuestionItem(int qid, int userId, String title, String content,
      int likeCount, String description) async {
    final question = ParseObject('Question')
      ..set('q_id', qid)
      ..set('q_person_id', userId)
      ..set('q_title', title)
      ..set('q_information', content)
      ..set('q_like', likeCount)
      ..set('q_description', description);
    final response = await question.save();
    if (!response.success) {
      throw Exception('Failed to create question: ${response.error?.message}');
    }
  }

  Future<List<ParseObject>> fetchQuestions() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Question'))
      ..orderByDescending('createdAt');
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    throw Exception('Failed to fetch questions');
  }
}