import 'package:muststudy/routes/route_names.dart';

class RouteGuard {
  static bool _isLoggedIn = false; // 这里应该从用户服务中获取实际登录状态
  
  static bool canActivate(String routeName) {
    // 不需要登录的路由
    final publicRoutes = [
      RouteNames.login,
    ];
    
    // 如果路由是公开的，直接允许访问
    if (publicRoutes.contains(routeName)) {
      return true;
    }
    
    // 检查登录状态
    if (!_isLoggedIn) {
      return false;
    }
    
    return true;
  }
  
  // 设置登录状态
  static void setLoggedIn(bool value) {
    _isLoggedIn = value;
  }
} 