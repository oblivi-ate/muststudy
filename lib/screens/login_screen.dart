import 'package:flutter/material.dart';
import '../repositories/Userinfo_respositories.dart';
import '../widgets/danmu_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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

  TextStyle get _pixelTextStyle => GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.white,
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
                          fontSize: 36,
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
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: '用户名',
                          hintStyle: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 密码输入框
                      TextFormField(
                        controller: _passwordController,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '密码',
                          hintStyle: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // 登录/注册按钮
                      _buildSubmitButton(),
                      const SizedBox(height: 16),
                      // 切换登录/注册模式
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? '没有账号?立即注册' : '已有账号?立即登录',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CB342)),
              ),
            )
          : Text(
              _isLogin ? '登录' : '注册',
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: const Color(0xFF7CB342),
                letterSpacing: 1.0,
              ),
            ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取所有用户信息
      final userList = await _userinfoRepository.fetchUserinfo();
      
      if (userList != null) {
        // 查找匹配的用户
        bool found = false;
        for (var user in userList) {
          if (user.get<String>('u_name') == _usernameController.text &&
              user.get<String>('u_password') == _passwordController.text) {
            found = true;
            break;
          }
        }

        if (found) {
          // 登录成功
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // 登录失败
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('用户名或密码错误')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            const SnackBar(content: Text('用户名已存在')),
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
          const SnackBar(content: Text('注册成功，请登录')),
        );
        
        setState(() {
          _isLogin = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('注册失败: $e')),
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