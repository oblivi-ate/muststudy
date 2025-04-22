import 'package:flutter/material.dart';
import 'package:muststudy/repositories/Question_respositories.dart';
import '../repositories/Userinfo_respositories.dart';
import '../widgets/danmu_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';
import 'package:muststudy/services/navigation_service.dart';
import 'package:muststudy/routes/route_names.dart';
import 'package:muststudy/routes/route_guard.dart';

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
        fontSize: 12,
        color: Colors.white,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleSmall => GoogleFonts.pressStart2p(
        fontSize: 10,
        color: Colors.white,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleError => GoogleFonts.pressStart2p(
        fontSize: 12,
        color: Colors.red,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleInput => GoogleFonts.pressStart2p(
        fontSize: 12,
        color: Colors.black,
        letterSpacing: 1.0,
        height: 1.2,
      );

  TextStyle get _pixelTextStyleHint => GoogleFonts.pressStart2p(
        fontSize: 12,
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 35,
                          color: Colors.white,
                          letterSpacing: 1,
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
                      const SizedBox(height: 70),
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
                      const SizedBox(height: 24),
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
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CB342)),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Log in' : 'register',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12,
                                      color: const Color(0xFF7CB342),
                                      letterSpacing: 1.0,
                                      height: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),

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
      final userList = await _userinfoRepository.fetchUserinfo();

      if (userList != null) {
        dynamic user;
        try {
          user = userList.firstWhere(
            (user) => 
              user.get<String>('u_name') == _usernameController.text &&
              user.get<String>('u_password') == _passwordController.text,
          );
        } catch (e) {
          user = null;  // 用户不存在时设置为 null
        }

        if (user != null) {
          if (!mounted) return;
          // 登录成功，导航到主屏幕
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('用户名或密码错误')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录错误: $e')),
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
      final userList = await _userinfoRepository.fetchUserinfo();
      
      if (userList != null) {
        // Check if username already exists
        final isUserExists = userList.any(
          (user) => user.get<String>('u_name') == _usernameController.text
        );

        if (isUserExists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already exists')),
          );
          return;
        }

        // Create new user with incremented ID
        final newUserId = userList.length + 1;
        await _userinfoRepository.createUserinfoItem(
          newUserId,
          _usernameController.text,
          _passwordController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful, please log in')),
        );
        
        setState(() {
          _isLogin = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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