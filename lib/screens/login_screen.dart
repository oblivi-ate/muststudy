import 'package:flutter/material.dart';
import '../repositories/Userinfo_respositories.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7CB342), Color(0xFF558B2F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo或标题
                    const Text(
                      "Must Study",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 用户名输入框
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: '用户名',
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
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '密码',
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF7CB342),
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