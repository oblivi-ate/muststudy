class StudyRecord {
  final DateTime date;
  final int duration;
  final String type;         // 学习类型，如"番茄钟"、"解题"等
  final String description;  // 描述信息
  final String status;       // 状态：完成、中断等
  final double hours;        // 学习时长（小时）

  StudyRecord({
    required this.date, 
    required this.duration,
    this.type = '番茄钟',
    this.description = '', 
    this.status = '完成',
    this.hours = 0,
  });
  
  // 从Map创建对象（用于JSON解析）
  factory StudyRecord.fromMap(Map<String, dynamic> map) {
    return StudyRecord(
      date: DateTime.parse(map['date']),
      duration: map['duration'] ?? 0,
      type: map['type'] ?? '番茄钟',
      description: map['description'] ?? '',
      status: map['status'] ?? '完成',
      hours: (map['hours'] ?? 0).toDouble(),
    );
  }
  
  // 转换为Map（用于JSON序列化）
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'type': type,
      'description': description,
      'status': status,
      'hours': hours,
    };
  }
} 