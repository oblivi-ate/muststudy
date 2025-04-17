import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AnswerRespositories {
  Future<void> createAnswer(int aid, String ainfo, int uid, int alike) async {
    final answer = ParseObject('Answer')
      ..set('a_id', aid)
      ..set('ainfo', ainfo)
      ..set('uid', uid)
      ..set('alike', alike);
    final response = await answer.save();
    if (!response.success) {
      throw Exception('Failed to create answer: ${response.error?.message}');
    }
    else{
      print('Answer created successfully');
    }
  }
  Future<List<ParseObject>> fetchAnswer() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Answer'));
    final response = await query.query();
    if (response.success && response.results!= null) {
      return response.results as List<ParseObject>; 
    }
    else{
      return []; 
    }
  }
}