import 'package:flutter/material.dart';
import '../util/places.dart';
import '../widgets/search_bar.dart';
import 'resource_details.dart';
import 'problem_details.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("学习论坛"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "今天想学点什么？",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomSearchBar(),
          ),
          _buildCategoryChips(),
          _buildRecommendedResources(context),
          _buildPopularProblems(),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ["算法", "数据结构", "系统设计", "数据库", "前端开发", "后端开发"];
    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(categories[index]),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedResources(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "推荐学习资源",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 220.0,
          padding: const EdgeInsets.only(left: 20.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: studyResources.length,
            itemBuilder: (context, index) {
              final resource = studyResources[index];
              return Container(
                width: 280.0,
                margin: const EdgeInsets.only(right: 16.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResourceDetails(resource: resource),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          resource.coverImage,
                          height: 120.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.title,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Icon(
                                    resource.type == 'video' ? Icons.play_circle_outline : Icons.article_outlined,
                                    size: 16.0,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    resource.duration,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Icon(
                                    Icons.person_outline,
                                    size: 16.0,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    resource.author,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProblems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "热门题目",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: problems.length,
          itemBuilder: (context, index) {
            final problem = problems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: problem.difficulty == "简单"
                            ? Colors.green[100]
                            : problem.difficulty == "中等"
                                ? Colors.orange[100]
                                : Colors.red[100],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        problem.difficulty,
                        style: TextStyle(
                          color: problem.difficulty == "简单"
                              ? Colors.green[900]
                              : problem.difficulty == "中等"
                                  ? Colors.orange[900]
                                  : Colors.red[900],
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        problem.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16.0, color: Colors.grey[600]),
                        const SizedBox(width: 4.0),
                        Text(
                          "通过率: ${(problem.successRate).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Icon(Icons.person_outline, size: 16.0, color: Colors.grey[600]),
                        const SizedBox(width: 4.0),
                        Text(
                          "提交次数: ${problem.solvedCount}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: problem.tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemDetails(problem: problem),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
