import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/dtos/profile_me_dto.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  final ValueChanged<String> onLanguageChanged;

  const ProfilePage({
    super.key,
    this.onLogout,
    required this.onLanguageChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _remote = ProfileRemoteDataSource();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
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
        _error = _extractError(e) ?? (Localizations.localeOf(context).languageCode == 'en'
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
    _timeZoneId = (me.timeZoneId == null || me.timeZoneId!.trim().isEmpty) ? 'Europe/Sarajevo' : me.timeZoneId;
    _notificationTime = _parseTime(me.notificationTimeLocal) ?? const TimeOfDay(hour: 15, minute: 0);
    _initialFirstName = _firstNameController.text.trim();
    _initialLastName = _lastNameController.text.trim();
    _initialPreferredLanguage = _preferredLanguage;
    _initialNotificationEnabled = _notificationEnabled;
    _initialNotificationTime = _formatTime(_notificationTime);
    _initialTimeZoneId = _timeZoneId ?? 'Europe/Sarajevo';
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
    final picked = await showTimePicker(context: context, initialTime: _notificationTime);
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
        notificationTimeLocal: _notificationEnabled ? _formatTime(_notificationTime) : null,
        timeZoneId: _notificationEnabled ? (_timeZoneId ?? 'Europe/Sarajevo') : null,
      );

      _applyProfile(updated);
      widget.onLanguageChanged(updated.preferredLanguage == 'en' ? 'en' : 'sr');

      if (!mounted) return;
      setState(() {
        _saving = false;
        _success = Localizations.localeOf(context).languageCode == 'en' ? 'Saved.' : 'Sačuvano.';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _extractError(e) ?? (Localizations.localeOf(context).languageCode == 'en'
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
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
                            decoration: const BoxDecoration(color: Color(0xFF6B9B6E), shape: BoxShape.circle),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_firstNameController.text} ${_lastNameController.text}'.trim().isEmpty
                                      ? (isEnglish ? 'Your profile' : 'Vaš profil')
                                      : '${_firstNameController.text} ${_lastNameController.text}',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4E6650),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6D806E),
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
                      child: Column(
                        children: [
                          _field(_firstNameController, isEnglish ? 'First name' : 'Ime'),
                          const SizedBox(height: AppSpacing.md),
                          _field(_lastNameController, isEnglish ? 'Last name' : 'Prezime'),
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
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4E6650),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _languageSwitcher(),
                          const SizedBox(height: AppSpacing.md),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              isEnglish ? 'Enable reminders' : 'Uključi podsetnike',
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4E6650),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: Color(0xFFCFE1CD)),
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isEnglish ? 'Reminder time' : 'Vreme podsetnika',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4E6650),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTime(_notificationTime),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6B9B6E),
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
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (_success != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          _success!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w700),
                        ),
                      ),
                    if (_hasChanges)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          isEnglish ? 'You have unsaved changes.' : 'Imate nesačuvane izmene.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFF6D806E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_saving || !_hasChanges) ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B9B6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _saving
                              ? (isEnglish ? 'Saving...' : 'Čuvanje...')
                              : (isEnglish ? 'Save changes' : 'Sačuvaj izmene'),
                          style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _saving ? null : widget.onLogout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6B9B6E), width: 1.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          context.l10n.logout,
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFF6B9B6E),
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0EADF)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      enabled: !_saving,
      onChanged: (_) => setState(() {
        _success = null;
        _error = null;
      }),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7FBF5),
        labelStyle: GoogleFonts.quicksand(color: const Color(0xFF7C917C), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA9C2A8), width: 1.4),
        ),
      ),
    );
  }

  Widget _readonlyField({required String label, required String value}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEEF4EC),
        labelStyle: GoogleFonts.quicksand(color: const Color(0xFF7C917C), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
        ),
      ),
      child: Text(
        value,
        style: GoogleFonts.quicksand(
          color: const Color(0xFF5B6D5C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _languageSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9B6E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B9B6E).withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LanguageOption(
              label: context.l10n.languageSerbian,
              isSelected: _preferredLanguage == 'sr',
              onTap: () {
                if (_preferredLanguage == 'sr' || _saving) return;
                setState(() {
                  _preferredLanguage = 'sr';
                  _success = null;
                  _error = null;
                });
                widget.onLanguageChanged('sr');
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _LanguageOption(
              label: context.l10n.languageEnglish,
              isSelected: _preferredLanguage == 'en',
              onTap: () {
                if (_preferredLanguage == 'en' || _saving) return;
                setState(() {
                  _preferredLanguage = 'en';
                  _success = null;
                  _error = null;
                });
                widget.onLanguageChanged('en');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B9B6E) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B9B6E) : const Color(0xFF6B9B6E).withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF6B9B6E),
          ),
        ),
      ),
    );
  }
}
