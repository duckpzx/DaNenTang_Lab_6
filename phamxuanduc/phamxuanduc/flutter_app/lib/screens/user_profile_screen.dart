import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ios_widgets.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  UserModel? _user;
  bool       _loading = true;
  String     _error   = '';

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _loadProfile();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final user = await _userService.getMe();
      setState(() { _user = user; });
      _animCtrl.forward(from: 0);
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : _error.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text(_error,
                              style: AppTextStyles.subheadline,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          IosPrimaryButton(
                            label: 'Retry',
                            onPressed: _loadProfile,
                          ),
                        ],
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // ── Top Bar ──────────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                              child: Row(
                                children: [
                                  Text('Profile',
                                      style: AppTextStyles.largeTitle),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _logout,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentRed
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accentRed
                                              .withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.power_settings_new_rounded,
                                        size: 18,
                                        color: AppColors.accentRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Avatar Section ────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                              child: Column(
                                children: [
                                  IosAvatar(
                                    name: _user?.username ?? '?',
                                    radius: 48,
                                    color: _user?.role == 'Admin'
                                        ? AppColors.accentOrange
                                        : AppColors.accent,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _user?.username ?? '',
                                    style: AppTextStyles.title2,
                                  ),
                                  const SizedBox(height: 8),
                                  IosBadge(
                                    label: _user?.role ?? '',
                                    color: _user?.role == 'Admin'
                                        ? AppColors.accentOrange
                                        : AppColors.accent,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Info Section ──────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                              child: IosListSection(
                                header: 'Account Info',
                                tiles: [
                                  IosListTile(
                                    leadingIcon: Icons.badge_outlined,
                                    iconColor: AppColors.accent,
                                    iconBgColor:
                                        AppColors.accent.withOpacity(0.12),
                                    title: 'User ID',
                                    trailing: Text(
                                      '${_user?.id ?? ''}',
                                      style: AppTextStyles.subheadline,
                                    ),
                                  ),
                                  IosListTile(
                                    leadingIcon: Icons.person_outline_rounded,
                                    iconColor: AppColors.accentGreen,
                                    iconBgColor:
                                        AppColors.accentGreen.withOpacity(0.12),
                                    title: 'Username',
                                    trailing: Text(
                                      _user?.username ?? '',
                                      style: AppTextStyles.subheadline,
                                    ),
                                  ),
                                  IosListTile(
                                    leadingIcon: Icons.shield_outlined,
                                    iconColor: _user?.role == 'Admin'
                                        ? AppColors.accentOrange
                                        : AppColors.accent,
                                    iconBgColor: (_user?.role == 'Admin'
                                            ? AppColors.accentOrange
                                            : AppColors.accent)
                                        .withOpacity(0.12),
                                    title: 'Role',
                                    trailing: IosBadge(
                                      label: _user?.role ?? '',
                                      color: _user?.role == 'Admin'
                                          ? AppColors.accentOrange
                                          : AppColors.accent,
                                    ),
                                  ),
                                  IosListTile(
                                    leadingIcon:
                                        Icons.calendar_today_outlined,
                                    iconColor: AppColors.accentGreen,
                                    iconBgColor:
                                        AppColors.accentGreen.withOpacity(0.12),
                                    title: 'Member Since',
                                    trailing: Text(
                                      _user != null
                                          ? _formatDate(_user!.createdAt)
                                          : '',
                                      style: AppTextStyles.subheadline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Logout Section ────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: IosListSection(
                                tiles: [
                                  IosListTile(
                                    leadingIcon:
                                        Icons.power_settings_new_rounded,
                                    iconColor: AppColors.accentRed,
                                    iconBgColor:
                                        AppColors.accentRed.withOpacity(0.12),
                                    title: 'Sign Out',
                                    onTap: _logout,
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 40),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
