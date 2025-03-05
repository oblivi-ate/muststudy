class StudyResource {
  final String id;
  final String title;
  final String coverImage;
  final String type; // 'video', 'document', 'quiz' etc.
  final String author;
  final String description;
  final String duration;
  final String difficulty;
  final List<String> tags;
  final int viewCount;
  final double rating;
  final String lastUpdated;

  const StudyResource({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.type,
    required this.author,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.tags,
    required this.viewCount,
    required this.rating,
    required this.lastUpdated,
  });
}

class Problem {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> tags;
  final int points;
  final String category;
  final Map<String, dynamic> testCases;
  final String solution;
  final int solvedCount;
  final double successRate;
  final List<String> relatedTopics;
  final String? author;
  final String? authorAvatar;
  final int? likes;
  final int? bookmarks;

  const Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tags,
    required this.points,
    required this.category,
    required this.testCases,
    required this.solution,
    required this.solvedCount,
    required this.successRate,
    required this.relatedTopics,
    this.author,
    this.authorAvatar,
    this.likes,
    this.bookmarks,
  });
}

class Reply {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  final List<String>? images;
  final String? audioUrl;
  final String? codeSnippet;
  final String? codeLanguage;
  final int likes;
  final bool isAccepted;

  const Reply({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.images,
    this.audioUrl,
    this.codeSnippet,
    this.codeLanguage,
    required this.likes,
    required this.isAccepted,
  });
}

final List<StudyResource> studyResources = [
  StudyResource(
    id: "1",
    title: "算法基础：数据结构入门",
    coverImage: "assets/1.jpeg",
    type: "video",
    author: "张教授",
    description: "深入浅出讲解基础数据结构，包括数组、链表、栈、队列等核心概念。\n\n"
        "课程要点：\n"
        "• 数组和字符串处理\n"
        "• 链表操作和实现\n"
        "• 栈和队列应用\n"
        "• 实战练习题解析",
    duration: "3小时",
    difficulty: "入门",
    tags: ["数据结构", "算法", "编程基础"],
    viewCount: 1200,
    rating: 4.8,
    lastUpdated: "2024-03-15",
  ),
  StudyResource(
    id: "2",
    title: "动态规划专题讲解",
    coverImage: "assets/2.jpeg",
    type: "document",
    author: "李博士",
    description: "系统讲解动态规划的思想方法和经典题型。\n\n"
        "包含内容：\n"
        "• DP基本概念\n"
        "• 经典题型分析\n"
        "• 解题技巧总结\n"
        "• 进阶问题探讨",
    duration: "2小时",
    difficulty: "进阶",
    tags: ["动态规划", "算法", "进阶技巧"],
    viewCount: 850,
    rating: 4.9,
    lastUpdated: "2024-03-10",
  ),
];

final List<Problem> problems = [
  Problem(
    id: "p1",
    title: "两数之和",
    description: "给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出和为目标值 target 的那两个整数，并返回它们的数组下标。",
    difficulty: "简单",
    tags: ["数组", "哈希表"],
    points: 100,
    category: "数组",
    testCases: {
      "input": {"nums": [2, 7, 11, 15], "target": 9},
      "output": [0, 1]
    },
    solution: "使用哈希表存储遍历过的数字和索引，当遍历到一个数字时，查找target减去该数字是否在哈希表中。",
    solvedCount: 5000,
    successRate: 95.5,
    relatedTopics: ["哈希表", "查找"],
    author: "张教授",
    authorAvatar: "https://ui-avatars.com/api/?name=张教授&background=random",
    likes: 2345,
    bookmarks: 1234,
  ),
  Problem(
    id: "p2",
    title: "最长回文子串",
    description: "给你一个字符串 s，找到 s 中最长的回文子串。如果字符串的反序与原始字符串相同，则该字符串称为回文字符串。",
    difficulty: "中等",
    tags: ["字符串", "动态规划"],
    points: 200,
    category: "字符串",
    testCases: {
      "input": {"s": "babad"},
      "output": "bab"
    },
    solution: "可以使用动态规划或中心扩展法解决。动态规划时定义dp[i][j]表示s[i..j]是否为回文串。",
    solvedCount: 3000,
    successRate: 75.8,
    relatedTopics: ["动态规划", "字符串处理"],
    author: "李博士",
    authorAvatar: "https://ui-avatars.com/api/?name=李博士&background=random",
    likes: 1856,
    bookmarks: 978,
  ),
];