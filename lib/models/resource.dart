class Resource {
  final String title;
  final String author;
  final String category;
  final String imageUrl;
  final String localImagePath;
  final String duration;
  final int viewCount;
  final double rating;

  Resource({
    required this.title,
    required this.author,
    required this.category,
    required this.imageUrl,
    this.localImagePath = '',
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
    title: '算法分析与设计笔记',
    author: '李老师',
    category: '算法',
    imageUrl: 'https://picsum.photos/200/300?random=2',
  ),
  Resource(
    title: '系统设计实践笔记',
    author: '王老师',
    category: '系统设计',
    imageUrl: 'https://picsum.photos/200/300?random=3',
  ),
  Resource(
    title: '数据库优化笔记',
    author: '赵老师',
    category: '数据库',
    imageUrl: 'https://picsum.photos/200/300?random=4',
  ),
  Resource(
    title: 'React开发实战笔记',
    author: '孙老师',
    category: '前端开发',
    imageUrl: 'https://picsum.photos/200/300?random=5',
  ),
  Resource(
    title: 'Spring Boot实践笔记',
    author: '周老师',
    category: '后端开发',
    imageUrl: 'https://picsum.photos/200/300?random=6',
  ),
];

// 示例视频数据
final List<Resource> videos = [
  Resource(
    title: '算法分析与设计教程',
    author: '陈老师',
    category: '算法',
    imageUrl: 'https://picsum.photos/200/300?random=7',
    duration: '45:30',
  ),
  Resource(
    title: '数据结构精讲',
    author: '刘老师',
    category: '数据结构',
    imageUrl: 'https://picsum.photos/200/300?random=8',
    duration: '32:15',
  ),
  Resource(
    title: '分布式系统设计',
    author: '赵老师',
    category: '系统设计',
    imageUrl: 'https://picsum.photos/200/300?random=9',
    duration: '28:45',
  ),
  Resource(
    title: 'MySQL性能优化',
    author: '钱老师',
    category: '数据库',
    imageUrl: 'https://picsum.photos/200/300?random=10',
    duration: '35:20',
  ),
  Resource(
    title: 'Vue.js实战教程',
    author: '孙老师',
    category: '前端开发',
    imageUrl: 'https://picsum.photos/200/300?random=11',
    duration: '40:15',
  ),
  Resource(
    title: 'Node.js进阶课程',
    author: '周老师',
    category: '后端开发',
    imageUrl: 'https://picsum.photos/200/300?random=12',
    duration: '38:30',
  ),
];

// 示例教材数据
final List<Resource> textbooks = [
  Resource(
    title: '算法导论',
    author: '孙老师',
    category: '算法',
    imageUrl: 'https://picsum.photos/200/300?random=13',
  ),
  Resource(
    title: '数据结构与算法分析',
    author: '周老师',
    category: '数据结构',
    imageUrl: 'https://picsum.photos/200/300?random=14',
  ),
  Resource(
    title: '系统设计面试指南',
    author: '吴老师',
    category: '系统设计',
    imageUrl: 'https://picsum.photos/200/300?random=15',
  ),
  Resource(
    title: '数据库系统概念',
    author: '郑老师',
    category: '数据库',
    imageUrl: 'https://picsum.photos/200/300?random=16',
  ),
  Resource(
    title: '现代前端开发实战',
    author: '冯老师',
    category: '前端开发',
    imageUrl: 'https://picsum.photos/200/300?random=17',
  ),
  Resource(
    title: 'Java高级开发指南',
    author: '蒋老师',
    category: '后端开发',
    imageUrl: 'https://picsum.photos/200/300?random=18',
  ),
]; 