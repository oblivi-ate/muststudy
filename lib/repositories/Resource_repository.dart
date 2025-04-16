import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ResourceRepository {
  Future<void> createResource(int rid, String title, String description, String url,
      String type, String difficulty, int authorId) async {
    final resource = ParseObject('Resource')
      ..set('r_id', rid)
      ..set('title', title)
      ..set('description', description)
      ..set('url', url)
      ..set('type', type)
      ..set('difficulty', difficulty)
      ..set('author_id', authorId);
    final response = await resource.save();
    if (!response.success) {
      throw Exception('Failed to create resource: ${response.error?.message}');
    }
  }

  Future<List<ParseObject>> fetchResources() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Resource'))
      ..orderByDescending('createdAt');
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    throw Exception('Failed to fetch resources');
  }
}