import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_currentPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.red));
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match.'), backgroundColor: Colors.red));
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildField(context, 'Current Password', _currentPassCtrl, Icons.lock_outline),
            const SizedBox(height: 16),
            _buildField(context, 'New Password', _newPassCtrl, Icons.lock_reset_outlined),
            const SizedBox(height: 16),
            _buildField(context, 'Confirm New Password', _confirmPassCtrl, Icons.check_circle_outline),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: cs.onPrimary, strokeWidth: 2))
                    : const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, TextEditingController ctrl, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

