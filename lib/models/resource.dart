class Resource {
  final String title;
  final String author;
  final String category;
  final String imageUrl;
  final String duration;
  final int viewCount;
  final double rating;

  Resource({
    required this.title,
    required this.author,
    required this.category,
    required this.imageUrl,
    this.duration = '',
    this.viewCount = 0,
    this.rating = 0.0,
  });
}

// 示例笔记数据
final List<Resource> notes = [
  Resource(
    title: '数据结构与算法基础笔记',
    author: '张老师',
    category: '数据结构',
    imageUrl: 'https://picsum.photos/200/300?random=1',
  ),
  Resource(
    title: '计算机网络知识总结',
    author: '李老师',
    category: '计算机网络',
    imageUrl: 'https://picsum.photos/200/300?random=2',
  ),
  Resource(
    title: '操作系统核心概念',
    author: '王老师',
    category: '操作系统',
    imageUrl: 'https://picsum.photos/200/300?random=3',
  ),
];

// 示例视频数据
final List<Resource> videos = [
  Resource(
    title: '算法分析与设计教程',
    author: '陈老师',
    category: '算法',
    imageUrl: 'https://picsum.photos/200/300?random=4',
    duration: '45:30',
  ),
  Resource(
    title: 'Java编程实战课程',
    author: '刘老师',
    category: '编程语言',
    imageUrl: 'https://picsum.photos/200/300?random=5',
    duration: '32:15',
  ),
  Resource(
    title: '数据库设计与优化',
    author: '赵老师',
    category: '数据库',
    imageUrl: 'https://picsum.photos/200/300?random=6',
    duration: '28:45',
  ),
];

// 示例教材数据
final List<Resource> textbooks = [
  Resource(
    title: '深入理解计算机系统',
    author: '孙老师',
    category: '计算机系统',
    imageUrl: 'https://picsum.photos/200/300?random=7',
  ),
  Resource(
    title: '数据结构与算法分析',
    author: '周老师',
    category: '数据结构',
    imageUrl: 'https://picsum.photos/200/300?random=8',
  ),
  Resource(
    title: '计算机组成原理',
    author: '吴老师',
    category: '计算机基础',
    imageUrl: 'https://picsum.photos/200/300?random=9',
  ),
]; 