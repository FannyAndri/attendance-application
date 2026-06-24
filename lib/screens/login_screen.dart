import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _departmentController;

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _departmentController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (_emailController.text == 'admin@admin.com' && _passwordController.text == 'admin123') {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/admin');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final success = await authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          await context.read<AppState>().initializeUser();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          _showError('Invalid email or password');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Login failed: $e');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _departmentController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _departmentController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Registration successful! Please login.');
        setState(() => _isLogin = true);
        _nameController.clear();
        _departmentController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Registration failed: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Login to manage your attendance'
                      : 'Sign up to start tracking your attendance',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _departmentController,
                          hintText: 'Department',
                          icon: Icons.business_outlined,
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isLogin ? _handleLogin : _handleRegister),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Login' : 'Register',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Register' : 'Login',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Demo Credentials',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: employee@company.com\nPassword: password123',
                          style: TextStyle(color: Colors.black87.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black45),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

