import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class QuestionRepository {
  Future<void> createQuestionItem(int qid, int userId, String title, String content,
      int likeCount, int viewCount, String tags, bool isSolved) async {
    final question = ParseObject('Question')
      ..set('q_id', qid)
      ..set('user_id', userId)
      ..set('title', title)
      ..set('content', content)
      ..set('like_count', likeCount)
      ..set('view_count', viewCount)
      ..set('tags', tags)
      ..set('is_solved', isSolved);
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

  Future<void> updateQuestionSolved(int qid, bool isSolved) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Question'))
      ..whereEqualTo('q_id', qid);
    final response = await query.query();
    if (response.success && response.results != null) {
      final question = response.results!.first as ParseObject;
      question.set('is_solved', isSolved);
      await question.save();
    }
  }
}