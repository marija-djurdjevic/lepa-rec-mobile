import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/dtos/profile_me_dto.dart';
import 'onboarding_story_reference_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  final ValueChanged<String> onLanguageChanged;
  final ProfileRemoteDataSource? remoteDataSource;
  final AuthLocalDataSource? authLocalDataSource;
  final Future<bool> Function(Uri uri)? openExternalLink;

  const ProfilePage({
    super.key,
    this.onLogout,
    required this.onLanguageChanged,
    this.remoteDataSource,
    this.authLocalDataSource,
    this.openExternalLink,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primary = Color(0xFF6B9B6E);
  static const Color _textPrimary = Color(0xFF3F4C45);
  static const Color _textMuted = Color(0xFF6A776F);
  static const Color _surfaceSoft = Color(0xFFF7FBF5);
  static const Color _surfaceReadOnly = Color(0xFFEEF4EC);
  static const Color _border = Color(0xFFD9E5D7);

  static final Uri _accountDeletionInfoUri = Uri.parse(
    'https://api.sagledaj.com/account-deletion',
  );
  static final Uri _privacyPolicyUri = Uri.parse(
    'https://api.sagledaj.com/privacy',
  );

  late final ProfileRemoteDataSource _remote;
  late final AuthLocalDataSource _authLocal;
  late final Future<bool> Function(Uri uri) _openExternalLink;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _deletingAccount = false;
  bool _isEditingPersonalInfo = false;
  String? _error;
  String? _success;

  String _email = '';
  String _preferredLanguage = 'sr';
  bool _notificationEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 15, minute: 0);
  String? _timeZoneId = 'Europe/Sarajevo';
  String _initialFirstName = '';
  String _initialLastName = '';
  String _initialPreferredLanguage = 'sr';
  bool _initialNotificationEnabled = false;
  String _initialNotificationTime = '15:00';
  String _initialTimeZoneId = 'Europe/Sarajevo';

  @override
  void initState() {
    super.initState();
    _remote = widget.remoteDataSource ?? ProfileRemoteDataSource();
    _authLocal = widget.authLocalDataSource ?? AuthLocalDataSource();
    _openExternalLink =
        widget.openExternalLink ??
        ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final me = await _remote.getMe();
      _applyProfile(me);
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            _extractError(e) ??
            (Localizations.localeOf(context).languageCode == 'en'
                ? 'Could not load profile.'
                : 'Nismo uspjeli učitati profil.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = Localizations.localeOf(context).languageCode == 'en'
            ? 'Could not load profile.'
            : 'Nismo uspjeli učitati profil.';
      });
    }
  }

  void _applyProfile(ProfileMeDto me) {
    _firstNameController.text = me.firstName;
    _lastNameController.text = me.lastName;
    _email = me.email;
    _preferredLanguage = me.preferredLanguage == 'en' ? 'en' : 'sr';
    _notificationEnabled = me.notificationEnabled;
    _timeZoneId = (me.timeZoneId == null || me.timeZoneId!.trim().isEmpty)
        ? 'Europe/Sarajevo'
        : me.timeZoneId;
    _notificationTime =
        _parseTime(me.notificationTimeLocal) ??
        const TimeOfDay(hour: 15, minute: 0);
    _initialFirstName = _firstNameController.text.trim();
    _initialLastName = _lastNameController.text.trim();
    _initialPreferredLanguage = _preferredLanguage;
    _initialNotificationEnabled = _notificationEnabled;
    _initialNotificationTime = _formatTime(_notificationTime);
    _initialTimeZoneId = _timeZoneId ?? 'Europe/Sarajevo';
    _isEditingPersonalInfo = false;
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hh = int.tryParse(parts[0]);
    final mm = int.tryParse(parts[1]);
    if (hh == null || mm == null) return null;
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;
    return TimeOfDay(hour: hh, minute: mm);
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool get _hasChanges {
    final currentFirst = _firstNameController.text.trim();
    final currentLast = _lastNameController.text.trim();
    final currentLang = _preferredLanguage;
    final currentEnabled = _notificationEnabled;
    final currentTime = _formatTime(_notificationTime);
    final currentTz = _timeZoneId ?? 'Europe/Sarajevo';

    if (currentFirst != _initialFirstName) return true;
    if (currentLast != _initialLastName) return true;
    if (currentLang != _initialPreferredLanguage) return true;
    if (currentEnabled != _initialNotificationEnabled) return true;
    if (!currentEnabled && !_initialNotificationEnabled) return false;
    if (currentTime != _initialNotificationTime) return true;
    if (currentTz != _initialTimeZoneId) return true;
    return false;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked == null) return;
    setState(() {
      _notificationTime = picked;
      _success = null;
      _error = null;
    });
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() {
        _error = Localizations.localeOf(context).languageCode == 'en'
            ? 'First name and last name are required.'
            : 'Ime i prezime su obavezni.';
        _success = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });

    try {
      final updated = await _remote.updateMe(
        firstName: firstName,
        lastName: lastName,
        preferredLanguage: _preferredLanguage,
        notificationEnabled: _notificationEnabled,
        notificationTimeLocal: _notificationEnabled
            ? _formatTime(_notificationTime)
            : null,
        timeZoneId: _notificationEnabled
            ? (_timeZoneId ?? 'Europe/Sarajevo')
            : null,
      );

      _applyProfile(updated);
      widget.onLanguageChanged(updated.preferredLanguage == 'en' ? 'en' : 'sr');

      if (!mounted) return;
      setState(() {
        _saving = false;
        _success = Localizations.localeOf(context).languageCode == 'en'
            ? 'Saved.'
            : 'Sačuvano.';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            _extractError(e) ??
            (Localizations.localeOf(context).languageCode == 'en'
                ? 'Could not save profile.'
                : 'Nismo uspjeli sačuvati profil.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = Localizations.localeOf(context).languageCode == 'en'
            ? 'Could not save profile.'
            : 'Nismo uspjeli sačuvati profil.';
      });
    }
  }

  Future<void> _openDeletionInfo() async {
    final opened = await _openExternalLink(_accountDeletionInfoUri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileDeleteAccountInfoOpenFailed),
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final opened = await _openExternalLink(_privacyPolicyUri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileDeleteAccountInfoOpenFailed),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    if (_deletingAccount || _saving) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(context.l10n.profileDeleteAccountConfirmTitle),
              content: Text(context.l10n.profileDeleteAccountConfirmMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.profileDeleteAccountCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    context.l10n.profileDeleteAccountAction,
                    style: const TextStyle(color: Color(0xFFB00020)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    await _deleteAccount();
  }

  Future<void> _handleSignedOut() async {
    await _authLocal.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Future<void> _deleteAccount() async {
    if (_deletingAccount) return;

    setState(() {
      _deletingAccount = true;
      _error = null;
      _success = null;
    });

    try {
      await _remote.deleteAccount();
      await _handleSignedOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileDeleteAccountSuccess)),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        await _handleSignedOut();
        return;
      }
      if (!mounted) return;
      setState(() {
        _deletingAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileDeleteAccountError)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deletingAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileDeleteAccountError)),
      );
    }
  }

  String? _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      if (message != null && message.trim().isNotEmpty) return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      appBar: AppTopBar(title: context.l10n.profile),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE7F2E3), Color(0xFFF7FBF5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFCFE1CD)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B9B6E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_firstNameController.text} ${_lastNameController.text}'
                                          .trim()
                                          .isEmpty
                                      ? (isEnglish
                                            ? 'Your profile'
                                            : 'Vaš profil')
                                      : '${_firstNameController.text} ${_lastNameController.text}',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionCard(
                      title: isEnglish ? 'Personal info' : 'Lični podaci',
                      trailing: IconButton(
                        tooltip: isEnglish
                            ? 'Edit personal info'
                            : 'Izmeni lične podatke',
                        onPressed: _saving
                            ? null
                            : () {
                                setState(() {
                                  _isEditingPersonalInfo =
                                      !_isEditingPersonalInfo;
                                  _success = null;
                                  _error = null;
                                });
                                if (!_isEditingPersonalInfo) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                        icon: Icon(
                          _isEditingPersonalInfo
                              ? Icons.check_rounded
                              : Icons.edit_outlined,
                          color: _primary,
                        ),
                      ),
                      child: Column(
                        children: [
                          _field(
                            _firstNameController,
                            isEnglish ? 'First name' : 'Ime',
                            enabled: _isEditingPersonalInfo && !_saving,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _field(
                            _lastNameController,
                            isEnglish ? 'Last name' : 'Prezime',
                            enabled: _isEditingPersonalInfo && !_saving,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _readonlyField(label: 'Email', value: _email),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionCard(
                      title: isEnglish ? 'Preferences' : 'Podešavanja',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.language,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _languageSwitcher(),
                          const SizedBox(height: AppSpacing.md),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              isEnglish
                                  ? 'Enable reminders'
                                  : 'Uključite podsetnike',
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _textMuted,
                              ),
                            ),
                            value: _notificationEnabled,
                            onChanged: _saving
                                ? null
                                : (v) => setState(() {
                                    _notificationEnabled = v;
                                    _success = null;
                                    _error = null;
                                  }),
                          ),
                          if (_notificationEnabled) ...[
                            OutlinedButton(
                              onPressed: _saving ? null : _pickTime,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFCFE1CD),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isEnglish
                                        ? 'Reminder time'
                                        : 'Vreme podsetnika',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _textMuted,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTime(_notificationTime),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionCard(
                      title: context.l10n.aboutApp,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: _saving
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const OnboardingStoryReferencePage(),
                                      ),
                                    );
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: _textMuted,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.menu_book_outlined, size: 18),
                            label: Text(
                              context.l10n.onboardingStoryReferenceButton,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextButton.icon(
                            onPressed: _saving ? null : _openPrivacyPolicy,
                            style: TextButton.styleFrom(
                              foregroundColor: _textMuted,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                            label: Text(
                              isEnglish ? 'Privacy Policy' : 'Politika privatnosti',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionCard(
                      title: context.l10n.profileDeleteAccountTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: (_saving || _deletingAccount)
                                  ? null
                                  : _openDeletionInfo,
                              style: TextButton.styleFrom(
                                foregroundColor: _textMuted,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.l10n.profileDeleteAccountLearnMore,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: (_saving || _deletingAccount)
                                  ? null
                                  : _showDeleteConfirmationDialog,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: _primary,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _deletingAccount
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _primary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      context.l10n.profileDeleteAccountAction,
                                      style: GoogleFonts.quicksand(
                                        color: _primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFFB00020),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_success != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          _success!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (_hasChanges)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          isEnglish
                              ? 'You have unsaved changes.'
                              : 'Imate nesačuvane izmene.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_saving || !_hasChanges) ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _saving
                              ? (isEnglish ? 'Saving...' : 'Čuvanje...')
                              : (isEnglish ? 'Save changes' : 'Sačuvajte izmene'),
                          style: GoogleFonts.quicksand(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: (_saving || _deletingAccount)
                            ? null
                            : widget.onLogout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _primary, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.l10n.logout,
                          style: GoogleFonts.quicksand(
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_saving)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: !enabled,
      onChanged: enabled
          ? (_) => setState(() {
              _success = null;
              _error = null;
            })
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? _surfaceSoft : _surfaceReadOnly,
        labelStyle: GoogleFonts.quicksand(
          color: _textMuted,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _readonlyField({required String label, required String value}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _surfaceReadOnly,
        labelStyle: GoogleFonts.quicksand(
          color: _textMuted,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
      ),
      child: Text(
        value,
        style: GoogleFonts.quicksand(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _languageSwitcher() {
    return DropdownButtonFormField<String>(
      value: _preferredLanguage,
      decoration: InputDecoration(
        filled: true,
        fillColor: _surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'sr',
          child: Text(
            context.l10n.languageSerbian,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Text(
            context.l10n.languageEnglish,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ),
      ],
      onChanged: _saving
          ? null
          : (value) {
              if (value == null || value == _preferredLanguage) return;
              setState(() {
                _preferredLanguage = value;
                _success = null;
                _error = null;
              });
            },
    );
  }
}
