import 'package:flutter/material.dart';
import '../repositories/Userinfo_respositories.dart';
import '../widgets/danmu_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  final _userinfoRepository = UserinfoRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 预加载字体
    GoogleFonts.pressStart2p();
  }

  TextStyle get _pixelTextStyle => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.white,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleSmall => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.white,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleError => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.red,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleInput => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.black,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleHint => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.grey,
        letterSpacing: 1.0,
        height: 1.2,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图片
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 弹幕
          DanmuWidget(
            safeAreas: [
              // 整体登录区域（包含标题和输入框）
              Rect.fromLTWH(
                MediaQuery.of(context).size.width / 2 - 150,  // 水平居中
                MediaQuery.of(context).size.height / 2 - 200, // 垂直位置
                300,  // 宽度
                400,  // 高度
              ),
            ],
            topPadding: 50,
            bottomPadding: 50,
          ),
          // 登录表单
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo或标题
                      Text(
                        "Must Study",
                        style: GoogleFonts.pressStart2p(
                          fontSize: 46,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              color: Color(0x4D000000),
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0x4D000000),
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 用户名输入框
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                        style: _pixelTextStyleInput,
                        decoration: InputDecoration(
                          errorStyle: _pixelTextStyleError,
                          hintText: 'Username',
                          hintStyle: _pixelTextStyleHint,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person, size: 24),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 密码输入框
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        style: _pixelTextStyleInput,
                        obscureText: true,
                        decoration: InputDecoration(
                          errorStyle: _pixelTextStyleError,
                          hintText: 'Password',
                          hintStyle: _pixelTextStyleHint,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock, size: 24),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 登录/注册按钮
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleSubmit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CB342)),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Log in' : 'register',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 14,
                                      color: const Color(0xFF7CB342),
                                      letterSpacing: 1.0,
                                      height: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 切换登录/注册模式
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? 'No account? Register now' : 'Already have an account? Log in',
                          style: _pixelTextStyleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 测试数据
      final testUsers = [
        {'u_name': 'test', 'u_password': '123456'},
        {'u_name': 'admin', 'u_password': 'admin'},
      ];

      // 查找匹配的用户
      bool found = false;
      for (var user in testUsers) {
        if (user['u_name'] == _usernameController.text &&
            user['u_password'] == _passwordController.text) {
          found = true;
          break;
        }
      }

      if (found) {
        // 登录成功
        if (!mounted) return;
        print('登录成功，准备跳转');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        // 登录失败
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username or password is incorrect',
              style: _pixelTextStyleError,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
            style: _pixelTextStyleError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取所有用户以检查用户名是否已存在
      final userList = await _userinfoRepository.fetchUserinfo();
      
      if (userList != null) {
        final isUserExists = userList.any(
          (user) => user.get<String>('u_name') == _usernameController.text
        );

        if (isUserExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Username already exists',
                style: _pixelTextStyleError,
              ),
            ),
          );
          return;
        }

        // 创建新用户
        final newUserId = userList.length + 1;
        await _userinfoRepository.createUserinfoItem(
          newUserId,
          _usernameController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful, please log in',
              style: _pixelTextStyleError,
            ),
          ),
        );
        
        setState(() {
          _isLogin = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: $e',
            style: _pixelTextStyleError,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        _handleLogin();
      } else {
        _handleRegister();
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 