import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../util/places.dart';
import 'resource_details.dart';
import '../widgets/search_bar.dart';
import '../models/resource.dart';
import 'package:muststudy/services/navigation_service.dart';

class LearningResourcesScreen extends StatefulWidget {
  const LearningResourcesScreen({Key? key}) : super(key: key);

  @override
  State<LearningResourcesScreen> createState() => _LearningResourcesScreenState();
}

class _LearningResourcesScreenState extends State<LearningResourcesScreen> {
  String _selectedCategory = '全部';
  String _selectedCollege = '全部';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 添加学院列表
  final List<String> _colleges = [
    '全部',
    '创新工程学院',
    '商学院',
    '国际学院',
  ];

  // 添加不同学院的标签映射
  final Map<String, List<String>> _collegeCategories = {
    '全部': [
      '全部',
      '数据结构',
      '算法',
      '系统设计',
      '数据库',
      '前端开发',
      '后端开发'
    ],
    '创新工程学院': [
      '全部',
      '数据结构',
      '算法',
      '系统设计',
      '数据库',
      '前端开发',
      '后端开发'
    ],
    '商学院': [
      '全部',
      '会计',
      '金融',
      '市场营销',
      '经济学',
      '管理学'
    ],
    '国际学院': [
      '全部',
      '国际贸易',
      '商务英语',
      '跨文化管理',
      '国际金融'
    ],
  };

  void _showCollegeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择学院',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _colleges.length,
                  itemBuilder: (context, index) {
                    final college = _colleges[index];
                    return ListTile(
                      title: Text(college),
                      trailing: _selectedCollege == college
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCollege = college;
                          // 重置分类选择
                          _selectedCategory = '全部';
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 修改筛选逻辑
  List<Resource> _getFilteredResources(List<Resource> resources) {
    return resources.where((resource) {
      final matchesCategory = _selectedCategory == '全部' || resource.category == _selectedCategory;
      final matchesCollege = _selectedCollege == '全部' || resource.college == _selectedCollege;
      final matchesSearch = _searchQuery.isEmpty ||
          resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesCollege && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFE4D4),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4D4),
        elevation: 0,
        title: Text(
          _selectedCollege,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.school, color: Colors.black87),
            onPressed: () => _showCollegeSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFFFE4D4),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                color: const Color(0xFFFFE4D4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "探索学习资源",
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '搜索学习资源...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryChips(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildResourceSection("笔记", Icons.note_alt_outlined, notes),
                        _buildResourceSection("视频", Icons.play_circle_outline, videos),
                        _buildResourceSection("教材", Icons.book_outlined, textbooks),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    // 获取当前选中学院的标签列表
    final categories = _collegeCategories[_selectedCollege] ?? _collegeCategories['全部']!;

    return SizedBox(
      height: 50.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : '全部';
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResourceSection(String title, IconData icon, List<Resource> resources) {
    final filteredResources = _getFilteredResources(resources);
    if (filteredResources.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "查看全部",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: filteredResources.length,
            itemBuilder: (context, index) {
              final resource = filteredResources[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    NavigationService().navigateToResourceDetails(resource);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 默认占位图
                              Icon(
                                _getIconForCategory(resource.category),
                                size: 40,
                                color: Colors.grey[300],
                              ),
                              // 如果有本地图片，优先使用本地图片
                              if (resource.category == "算法")
                                Image.asset(
                                  'assets/images/algorithm_icon.png',
                                  fit: BoxFit.cover,
                                )
                              else if (resource.category == "数据结构")
                                Image.asset(
                                  'assets/images/data_structure_icon.png',
                                  fit: BoxFit.cover,
                                )
                              else if (resource.category == "系统设计")
                                Image.asset(
                                  'assets/images/system_design_icon.png',
                                  fit: BoxFit.cover,
                                )
                              else if (resource.category == "数据库")
                                Image.asset(
                                  'assets/images/database_icon.png',
                                  fit: BoxFit.cover,
                                )
                              else if (resource.category == "前端开发")
                                Image.asset(
                                  'assets/images/frontend_icon.png',
                                  fit: BoxFit.cover,
                                )
                              else if (resource.category == "后端开发")
                                Image.asset(
                                  'assets/images/backend_icon.png',
                                  fit: BoxFit.cover,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(icon, size: 16.0, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  resource.author,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                resource.category,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case "算法":
        return Icons.architecture;
      case "数据结构":
        return Icons.data_array;
      case "系统设计":
        return Icons.design_services;
      case "数据库":
        return Icons.storage;
      case "前端开发":
        return Icons.web;
      case "后端开发":
        return Icons.dns;
      default:
        return Icons.book;
    }
  }
}

// 添加搜索代理类
class ResourceSearchDelegate extends SearchDelegate<Resource> {
  final List<Resource> resources;

  ResourceSearchDelegate({required this.resources});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Resource(
          id: '',
          title: '',
          description: '',
          category: '',
          imageUrl: '',
          author: '',
          college: '',
        ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = resources.where((resource) {
      return resource.title.toLowerCase().contains(query.toLowerCase()) ||
          resource.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final resource = results[index];
        return ListTile(
          title: Text(resource.title),
          subtitle: Text(resource.description),
          onTap: () {
            close(context, resource);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : resources.where((resource) {
            return resource.title.toLowerCase().contains(query.toLowerCase()) ||
                resource.description.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final resource = suggestions[index];
        return ListTile(
          title: Text(resource.title),
          subtitle: Text(resource.description),
          onTap: () {
            query = resource.title;
            showResults(context);
          },
        );
      },
    );
  }
} 