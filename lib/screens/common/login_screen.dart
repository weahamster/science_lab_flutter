import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../teacher/teacher_main_screen.dart';
import '../student/student_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _schoolCodeController = TextEditingController();  // 학교 코드
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool _isLogin = true;
  String _selectedRole = 'student';
  String? _selectedSchoolId;
  String? _schoolName;

  Future<void> _verifySchoolCode() async {
    final code = _schoolCodeController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학교 코드를 입력해주세요')),
      );
      return;
    }

    try {
      // schools 테이블에서 학교 코드 확인
      final response = await _supabase
          .from('schools')
          .select('id, name')
          .eq('school_code', code)
          .single();
      
      setState(() {
        _selectedSchoolId = response['id'];
        _schoolName = response['name'];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response['name']} 확인되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 학교 코드를 입력해주세요')),
      );
      setState(() {
        _selectedSchoolId = null;
        _schoolName = null;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty || 
        _selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Auth 회원가입
      final authResponse = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user != null) {
        // 2. users 테이블에 추가 정보 저장
        await _supabase.from('users').insert({
          'id': authResponse.user!.id,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'role': _selectedRole,
          'school': _schoolName,  // 학교명 저장
          'created_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다!')),
        );
        
        // 3. 자동 로그인 및 화면 이동
        await _checkUserRoleAndNavigate(_emailController.text.trim());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (response.user != null) {
        await _checkUserRoleAndNavigate(response.user!.email!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _checkUserRoleAndNavigate(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('email', email)
          .single();
      
      final role = response['role'];
      
      if (!mounted) return;
      
      if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherMainScreen()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentMainScreen()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.science,
                    size: 64,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '과학실 관리 시스템',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? '로그인' : '회원가입',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 학교 코드 입력
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _schoolCodeController,
                            decoration: InputDecoration(
                              labelText: '학교 코드',
                              prefixIcon: const Icon(Icons.school),
                              border: const OutlineInputBorder(),
                              helperText: _schoolName,
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _verifySchoolCode,
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 역할 선택
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRole,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Text('학생'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'teacher',
                                    child: Text('교사'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_isLogin ? _handleLogin : _handleSignUp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? '로그인' : '회원가입',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _nameController.clear();
                        _schoolCodeController.clear();
                        _selectedSchoolId = null;
                        _schoolName = null;
                        _selectedRole = 'student';
                      });
                    },
                    child: Text(
                      _isLogin 
                          ? '계정이 없으신가요? 회원가입' 
                          : '이미 계정이 있으신가요? 로그인',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}