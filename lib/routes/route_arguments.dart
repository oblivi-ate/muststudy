class RouteArguments {
  final dynamic data;
  final Map<String, dynamic>? params;
  
  RouteArguments({this.data, this.params});
  
  // 资源详情参数
  static RouteArguments resourceDetails(dynamic resource) {
    return RouteArguments(data: resource);
  }
  
  // 问题详情参数
  static RouteArguments problemDetails(dynamic problem) {
    return RouteArguments(data: problem);
  }
} 