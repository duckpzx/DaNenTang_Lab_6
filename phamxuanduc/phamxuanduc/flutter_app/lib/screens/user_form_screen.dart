import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ios_widgets.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? editUser;

  const UserFormScreen({super.key, this.editUser});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final UserService _userService = UserService();

  String _selectedRole = 'User';
  bool   _loading      = false;
  bool   _obscure      = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  bool get _isEdit => widget.editUser != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    if (_isEdit) {
      _usernameCtrl.text = widget.editUser!.username;
      _selectedRole      = widget.editUser!.role;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await _userService.updateUser(
          widget.editUser!.id,
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
          role:     _selectedRole,
        );
      } else {
        await _userService.createUser(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
          role:     _selectedRole,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.accentGreen, size: 18),
              const SizedBox(width: 10),
              Text(_isEdit ? 'User updated.' : 'User created.'),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.accentRed, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      e.toString().replaceFirst('Exception: ', ''))),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit User' : 'New User'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Icon ──────────────────────────────────────────
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            _isEdit
                                ? Icons.edit_outlined
                                : Icons.person_add_outlined,
                            size: 32,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _isEdit ? 'Edit User' : 'New User',
                          style: AppTextStyles.title2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          _isEdit
                              ? 'Update user information'
                              : 'Fill in the details below',
                          style: AppTextStyles.subheadline,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Fields Section ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'ACCOUNT DETAILS',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.border, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            IosTextField(
                              controller: _usernameCtrl,
                              label: 'Username',
                              prefixIcon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter username';
                                }
                                if (v.length < 3) return 'Min 3 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            IosTextField(
                              controller: _passwordCtrl,
                              label: _isEdit
                                  ? 'New Password (leave blank to keep)'
                                  : 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (!_isEdit &&
                                    (v == null || v.isEmpty)) {
                                  return 'Enter password';
                                }
                                if (v != null &&
                                    v.isNotEmpty &&
                                    v.length < 6) {
                                  return 'Min 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Role Selector ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'ROLE',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Row(
                        children: ['User', 'Admin'].map((role) {
                          final selected = _selectedRole == role;
                          final color = role == 'Admin'
                              ? AppColors.accentOrange
                              : AppColors.accent;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: role == 'User' ? 8 : 0),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedRole = role),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? color.withOpacity(0.15)
                                        : AppColors.card,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? color.withOpacity(0.5)
                                          : AppColors.border,
                                      width: selected ? 1.5 : 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        role == 'Admin'
                                            ? Icons
                                                .admin_panel_settings_outlined
                                            : Icons.person_outline_rounded,
                                        size: 20,
                                        color: selected
                                            ? color
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        role,
                                        style: AppTextStyles.callout.copyWith(
                                          color: selected
                                              ? color
                                              : AppColors.textSecondary,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 36),

                      // ── Submit Button ─────────────────────────────────
                      IosPrimaryButton(
                        label: _isEdit ? 'Save Changes' : 'Create User',
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),

                      // Cancel
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                                color: AppColors.border, width: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
