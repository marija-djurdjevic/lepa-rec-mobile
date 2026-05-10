import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lepa_rec_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';

class OnboardingRegistrationPage extends StatefulWidget {
  const OnboardingRegistrationPage({super.key});

  @override
  State<OnboardingRegistrationPage> createState() => _OnboardingRegistrationPageState();
}

class _OnboardingRegistrationPageState extends State<OnboardingRegistrationPage> {
  final _authRemote = AuthRemoteDataSource();
  final _authLocal = AuthLocalDataSource();
  final _onboardingLocal = OnboardingLocalDataSource();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _submitting = false;
  String? _error;
  bool _notificationEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 15, minute: 0);
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _timeToApiFormat(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _timeLabel(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool _isValidEmail(String email) {
    final value = email.trim();
    return value.contains('@') && value.contains('.');
  }

  String? _emailError() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return null;
    if (_isValidEmail(email)) return null;
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

  String? _confirmPasswordError() {
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty) return null;
    if (confirm == _passwordController.text) return null;
    return _isEnglish ? 'Passwords do not match.' : 'Lozinke se ne poklapaju.';
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(context: context, initialTime: _notificationTime);
    if (picked == null) return;
    setState(() {
      _notificationTime = picked;
    });
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _error = _isEnglish ? 'Please fill all required fields.' : 'Molimo popunite sva obavezna polja.';
      });
      return;
    }

    final e1 = _emailError();
    final e2 = _passwordError();
    final e3 = _confirmPasswordError();
    if (e1 != null || e2 != null || e3 != null) {
      setState(() {
        _error = e1 ?? e2 ?? e3;
      });
      return;
    }

    final sessionId = await _onboardingLocal.readSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      setState(() {
        _error = _isEnglish
            ? 'Onboarding session is missing. Please restart registration.'
            : 'Nedostaje onboarding sesija. Molimo pokrenite registraciju ponovo.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final auth = await _authRemote.registerWithOnboarding(
        email: email,
        password: password,
        onboardingSessionId: sessionId,
        firstName: firstName,
        lastName: lastName,
        notificationEnabled: _notificationEnabled,
        notificationTimeLocal: _notificationEnabled ? _timeToApiFormat(_notificationTime) : null,
        timeZoneId: 'Europe/Sarajevo',
      );

      await _authLocal.saveSession(auth);
      await _onboardingLocal.clearSessionId();

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final message = data is Map<String, dynamic> ? (data['message'] as String?) : null;
      final normalized = (message ?? '').toLowerCase();
      setState(() {
        _error = normalized.contains('email is already registered')
            ? (_isEnglish
                ? 'This email is already registered. Please log in or use another email.'
                : 'Ovaj email je već registrovan. Prijavite se ili koristite drugi email.')
            : (_isEnglish
                ? 'Could not complete registration. Please try again.'
                : 'Nismo uspjeli završiti registraciju. Pokušajte ponovo.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not complete registration. Please try again.'
            : 'Nismo uspjeli završiti registraciju. Pokušajte ponovo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEnglish ? 'Save your progress' : 'Sačuvaj svoj napredak';
    final helper = _isEnglish
        ? 'Best moments are with morning coffee, on the bus, or near the end of your day when you can take 5 minutes for yourself.'
        : 'Najbolje da ovo bude uz jutarnju kafu, kada si u autobusu ili pred kraj dana kada imaš vremena da izdvojiš 5 minuta za sebe.';

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _isEnglish ? 'Finish registration' : 'Završi registraciju',
                  style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl + AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(fontSize: 30, fontWeight: FontWeight.w700, color: const Color(0xFF6B9B6E)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildField(_firstNameController, _isEnglish ? 'First name' : 'Ime'),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(_lastNameController, _isEnglish ? 'Last name' : 'Prezime'),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, errorText: _emailError()),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(
                    _passwordController,
                    _isEnglish ? 'Password' : 'Lozinka',
                    obscureText: !_showPassword,
                    errorText: _passwordError(),
                    suffix: IconButton(
                      onPressed: _submitting ? null : () => setState(() => _showPassword = !_showPassword),
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(
                    _confirmPasswordController,
                    _isEnglish ? 'Confirm password' : 'Potvrda lozinke',
                    obscureText: !_showConfirmPassword,
                    errorText: _confirmPasswordError(),
                    suffix: IconButton(
                      onPressed: _submitting ? null : () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isEnglish ? 'Enable reminders' : 'Uključi podsetnike',
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4E6650)),
                    ),
                    value: _notificationEnabled,
                    onChanged: _submitting ? null : (v) => setState(() => _notificationEnabled = v),
                  ),
                  if (_notificationEnabled) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _submitting ? null : _pickNotificationTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _isEnglish ? 'Reminder time' : 'Vreme podsetnika',
                            style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4E6650)),
                          ),
                          const Spacer(),
                          Text(
                            _timeLabel(_notificationTime),
                            style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF6B9B6E)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      helper,
                      style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF6D806E), height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_submitting)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: !_submitting,
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
}
