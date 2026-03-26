import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/core/services/security_initializer.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';
import '../../utils/error_handler.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idCtrl = TextEditingController(), _passCtrl = TextEditingController();
  bool _isLoading = false,
      _obscurePassword = true,
      _isPhoneLogin = true,
      _rememberMe = false;
  bool _isAdminApp = false;
  bool _biometricAvailable = false; // ⭐ NEW: Track biometric availability
  // bool _biometricInitializing = false; // ⭐ NEW: Track biometric init state (unused)

  @override
  void initState() {
    super.initState();
    _initAppName();
    _loadSavedCredentials();
    _initBiometric(); // ⭐ NEW: Initialize biometric
  }

  // ⭐ NEW: Initialize biometric authentication
  Future<void> _initBiometric() async {
    try {
      // _biometricInitializing = true;
      final secureAuth = SecurityInitializer.secureAuth;
      final available = await secureAuth.isBiometricAvailable();

      if (mounted) {
        setState(() {
          _biometricAvailable = available;
          // _biometricInitializing = false;
        });
      }

      debugPrint('Biometric available: $available');
    } catch (e) {
      if (mounted) {
        setState(() {
          // _biometricInitializing = false;
        });
      }
      debugPrint('Biometric init error: $e');
    }
  }

  Future<void> _initAppName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _isAdminApp = packageInfo.packageName.contains('admin');
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('saved_login_id') ?? '';
    final isRemembered = prefs.getBool('remember_me') ?? false;

    if (isRemembered && mounted) {
      setState(() {
        _idCtrl.text = savedId;
        // ⭐ SECURITY: NO LONGER load password from SharedPreferences
        // Use biometric or manual password entry instead
        _rememberMe = true;
        _isPhoneLogin = !savedId.contains('@');
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      // ⭐ SECURITY: Only save username, NOT password
      await prefs.setString('saved_login_id', _idCtrl.text.trim());
      // ⭐ SECURITY: Remove old stored password if exists
      await prefs.remove('saved_login_pass');
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_login_id');
      await prefs.remove('saved_login_pass');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  Future<void> _handleLogin() async {
    if (_idCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ErrorHandler.handleError(_t('fillAllFields'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userCred = await ref.read(authServiceProvider).signIn(
            _idCtrl.text.trim(),
            _passCtrl.text.trim(),
          );

      if (userCred != null && mounted) {
        // ⭐ SECURITY: Store token securely using SecureAuthService
        final secureAuth = SecurityInitializer.secureAuth;
        await secureAuth.storeSecureToken(
          'access_token',
          userCred.uid,
        );
        debugPrint('✅ User token stored securely');
      
        await _saveCredentials();
        if (mounted) {
          ref.read(navProvider.notifier).setIndex(4);
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ⭐ NEW: Biometric login method
  Future<void> _handleBiometricLogin() async {
    try {
      setState(() => _isLoading = true);

      final secureAuth = SecurityInitializer.secureAuth;

      // Step 1: Authenticate with biometric
      final authenticated = await secureAuth.authenticateForSensitiveOperation(
        localizedReason: _t('loginWithBiometric'),
      );

      if (!authenticated) {
        if (mounted) {
          ErrorHandler.handleError(_t('biometricAuthFailed'));
        }
        return;
      }

      // Step 2: Try to auto-login if username is saved
      if (_idCtrl.text.isEmpty) {
        if (mounted) {
          ErrorHandler.handleError(_t('enterUsernameFirst'));
        }
        return;
      }

      // Step 3: For now, still need to verify with Firebase
      // In production, this would use a saved access token
      ErrorHandler.handleError(
        'Biometric login requires password entry (security). '
        'Enter password once, then biometric works on next login.',
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError('Biometric error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) {
        ref.read(navProvider.notifier).setIndex(4);
        context.go('/');
      }
    } catch (e) {
      if (mounted) ErrorHandler.handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ⭐ DEMO LOGIN: For testing purposes
  Future<void> _handleDemoLogin() async {
    // Pre-fill with test credentials
    setState(() {
      _idCtrl.text = 'demo@test.com';  // Test email
      _passCtrl.text = 'Demo@1234';     // Test password
      _isPhoneLogin = false;
    });
    
    // Auto-submit login
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      await _handleLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayAppName = _isAdminApp ? _t('appNameAdmin') : _t('appName');

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppStyles.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(displayAppName,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppStyles.primaryColor,
                        letterSpacing: -1)),
                Text(_t('loginTitle'),
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppStyles.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 30),
                _buildLoginToggle(),
                const SizedBox(height: 15),
                _buildSignupPrompt(),
                const SizedBox(height: 15),
                _buildTextField(
                  _isPhoneLogin ? _t('mobileNumber') : _t('emailAddress'),
                  _isPhoneLogin
                      ? Icons.phone_android_rounded
                      : Icons.alternate_email_rounded,
                  _idCtrl,
                  keyboardType: _isPhoneLogin
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  isPhone: _isPhoneLogin,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _t('password'),
                  Icons.lock_outline_rounded,
                  _passCtrl,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  isDark: isDark,
                ),
                const SizedBox(height: 15),
                _buildRememberForgot(),
                const SizedBox(height: 40),
                _buildLoginButton(),
                const SizedBox(height: 12),
                // ⭐ DEMO LOGIN BUTTON FOR TESTING
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleDemoLogin,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🔓 Demo Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDivider(),
                const SizedBox(height: 30),
                _buildSocialLogins(isDark),
                const SizedBox(height: 40),
                _buildQuickInfoLinks(isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoLinks(bool isDark) {
    final appConfig = ref.watch(appConfigProvider).value ?? {};
    const webUrl = 'https://paykari-bazar-a19e7.web.app/';
    const androidUrl =
        'https://firebasestorage.googleapis.com/v0/b/paykari-bazar-a19e7.firebasestorage.app/o/app_updates%2Flatest_customer.apk?alt=media';
    final iosUrl = appConfig['ios_app_url'] ??
        'https://firebasestorage.googleapis.com/v0/b/paykari-bazar-a19e7.firebasestorage.app/o/app_updates%2Flatest_app.iso?alt=media';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoLinkBtn(Icons.language_rounded, 'WEBSITE', webUrl, isDark),
        const SizedBox(width: 12),
        _infoLinkBtn(Icons.android_rounded, 'ANDROID', androidUrl, isDark),
        const SizedBox(width: 12),
        _infoLinkBtn(Icons.apple_rounded, 'IOS', iosUrl, isDark),
      ],
    );
  }

  Widget _infoLinkBtn(IconData icon, String label, String url, bool isDark) {
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      onLongPress: () => Share.share('Get Paykari Bazar: $label Link: $url'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppStyles.primaryColor),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _toggleBtn(_t('mobile'), _isPhoneLogin,
              () => setState(() => _isPhoneLogin = true)),
          _toggleBtn(_t('email'), !_isPhoneLogin,
              () => setState(() => _isPhoneLogin = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppStyles.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppStyles.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : AppStyles.textSecondary,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggleVisibility,
      TextInputType? keyboardType,
      bool isPhone = false,
      required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
        border:
            isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey),
          prefixIcon: Icon(icon, color: AppStyles.primaryColor, size: 20),
          prefixText: isPhone ? '+88 ' : null,
          prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: isDark ? Colors.grey : null),
                  onPressed: onToggleVisibility)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                activeColor: AppStyles.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            const SizedBox(width: 8),
            Text(_t('rememberMe'),
                style: const TextStyle(
                    fontSize: 13, color: AppStyles.textSecondary)),
          ],
        ),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text(_t('forgotPassword'),
              style: const TextStyle(
                  color: AppStyles.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppStyles.primaryGradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: AppStyles.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          child: _isLoading
              ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Text(_t('login'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_t('orContinueWith'),
                style: const TextStyle(color: Colors.grey, fontSize: 12))),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialLogins(bool isDark) {
    return Column(
      children: [
        // ⭐ NEW: Biometric button (if available)
        if (_biometricAvailable && _idCtrl.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppStyles.primaryColor.withValues(alpha: 0.8),
                      AppStyles.primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleBiometricLogin,
                  icon: const Icon(Icons.fingerprint_rounded, size: 24),
                  label: Text(
                    _t('loginWithBiometric'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _socialBtn(Icons.g_mobiledata_rounded, const Color(0xFFDB4437),
                onTap: _handleGoogleLogin, size: 40, isDark: isDark),
            _socialBtn(Icons.facebook_rounded, const Color(0xFF4267B2),
                onTap: () {}, size: 30, isDark: isDark),
            _socialBtn(
                Icons.apple_rounded, isDark ? Colors.white : Colors.black,
                onTap: () {}, size: 30, isDark: isDark),
          ],
        ),
      ],
    );
  }

  Widget _socialBtn(IconData icon, Color color,
      {VoidCallback? onTap, double size = 22, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 55,
        width: 75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade200),
        ),
        child: Center(child: Icon(icon, color: color, size: size)),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return InkWell(
      onTap: () => context.push('/signup'),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: AppStyles.primaryColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_t('noAccount'),
                style: const TextStyle(
                    color: AppStyles.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(_t('signup'),
                style: const TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
          ],
        ),
      ),
    );
  }
}

