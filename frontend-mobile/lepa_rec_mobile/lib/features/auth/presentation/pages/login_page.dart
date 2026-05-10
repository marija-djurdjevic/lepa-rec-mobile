import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../../onboarding/data/datasources/onboarding_remote_datasource.dart';
import '../auth_post_auth_router.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _remote = AuthRemoteDataSource();
  final _local = AuthLocalDataSource();
  final _onboardingRemote = OnboardingRemoteDataSource();
  final _onboardingLocal = OnboardingLocalDataSource();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  final Color bgColor = const Color(0xFFF5F9F3);
  final Color titleColor = const Color(0xFF6B9B6E);
  final Color sageGreen = const Color(0xFF6B9B6E);

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _emailError() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return null;
    if (email.contains('@') && email.contains('.')) return null;
    return _isEnglish ? 'Please enter a valid email.' : 'Unesite ispravan email.';
  }

  String? _passwordError() {
    final password = _passwordController.text;
    if (password.isEmpty) return null;
    if (password.length >= 8) return null;
    return _isEnglish
        ? 'Password must have at least 8 characters.'
        : 'Lozinka mora imati najmanje 8 karaktera.';
  }

  Future<void> _loginWithEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = _isEnglish ? 'Please fill in email and password.' : 'Unesite email i lozinku.';
      });
      return;
    }

    final e1 = _emailError();
    final e2 = _passwordError();
    if (e1 != null || e2 != null) {
      setState(() {
        _error = e1 ?? e2;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = await _remote.login(email: email, password: password);
      await _local.saveSession(auth);

      if (!mounted) return;
      await AuthPostAuthRouter.routeAfterAuth(context, auth);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish ? 'Login failed. Check your credentials.' : 'Prijava nije uspjela. Provjerite podatke.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final account = await googleSignIn.authenticate();

      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google idToken is missing.');
      }

      final auth = await _remote.googleLogin(idToken);

      await _local.saveSession(auth);

      if (!mounted) return;
      await AuthPostAuthRouter.routeAfterAuth(context, auth);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish ? 'Login failed. Please try again.' : 'Prijava nije uspjela. Pokušajte ponovo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _startAnonymousOnboarding() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await _onboardingRemote.startSession();
      await _onboardingLocal.saveSessionId(session.onboardingSessionId);

      if (!mounted) return;
      Navigator.of(context).pushNamed('/onboarding/language');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not start registration. Please try again.'
            : 'Nismo uspjeli pokrenuti registraciju. Pokušajte ponovo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildContent(),
          if (_loading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    final bool compact = h < 740;
    final double topSpace = compact ? 24 : 44;
    final double titleBottom = compact ? 14 : 20;
    final double imageHeight = compact ? 170 : 220;
    final double sectionGap = compact ? 10 : 14;
    final double bottomGap = compact ? 20 : 28;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topSpace),
            Text(
              context.l10n.appTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: compact ? 46 : 52,
                fontWeight: FontWeight.w700,
                color: titleColor,
                letterSpacing: -1.0,
              ),
            ),
            SizedBox(height: titleBottom),
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Image.asset(
                'assets/images/loginlogo.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError(),
              ),
            ),
            SizedBox(height: sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildField(
                controller: _passwordController,
                label: _isEnglish ? 'Password' : 'Lozinka',
                obscureText: !_showPassword,
                errorText: _passwordError(),
                suffix: IconButton(
                  onPressed: _loading ? null : () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            SizedBox(height: sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildEmailLoginButton(),
            ),
            SizedBox(height: sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildOrSeparator(),
            ),
            SizedBox(height: sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildGoogleButton(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildRegisterLinkRow(),
            ),
            if (_error != null) ...[
              SizedBox(height: sectionGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildErrorBox(),
              ),
            ],
            SizedBox(height: bottomGap),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailLoginButton() {
    final label = _isEnglish ? 'Log in' : 'Prijavite se';
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _loginWithEmailPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                'G',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4285F4),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                context.l10n.loginWithGoogle,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLinkRow() {
    final prefix = _isEnglish ? "Don't have an account?" : 'Nemate nalog?';
    final link = _isEnglish ? 'Register here' : 'Registrujte se';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4E6650),
          ),
        ),
        TextButton(
          onPressed: _loading ? null : _startAnonymousOnboarding,
          style: TextButton.styleFrom(
            foregroundColor: sageGreen,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            link,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrSeparator() {
    final label = _isEnglish ? 'Or' : 'Ili';
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFD6E2D3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6D806E),
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFD6E2D3),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _error ?? (_isEnglish ? 'Something went wrong.' : 'Došlo je do greške.'),
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: !_loading,
      onChanged: (_) => setState(() {
        _error = null;
      }),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7FBF5),
        labelStyle: GoogleFonts.quicksand(color: const Color(0xFF7C917C), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9E5D7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFA9C2A8), width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9E5D7), width: 1),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
