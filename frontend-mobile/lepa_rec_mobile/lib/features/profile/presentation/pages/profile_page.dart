import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  final ValueChanged<String> onLanguageChanged;

  const ProfilePage({
    super.key,
    this.onLogout,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguageCode =
        Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
    final selectedLanguage = currentLanguageCode == 'en' ? 'en' : 'sr';

    return Scaffold(
      appBar: AppTopBar(title: context.l10n.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.language,
                style: const TextStyle(
                  color: Color(0xFF6B9B6E),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6B9B6E).withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _LanguageOption(
                        label: context.l10n.languageSerbian,
                        isSelected: selectedLanguage == 'sr',
                        onTap: () {
                          if (selectedLanguage == 'sr') return;
                          onLanguageChanged('sr');
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _LanguageOption(
                        label: context.l10n.languageEnglish,
                        isSelected: selectedLanguage == 'en',
                        onTap: () {
                          if (selectedLanguage == 'en') return;
                          onLanguageChanged('en');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B9B6E), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.logout,
                    style: const TextStyle(
                      color: Color(0xFF6B9B6E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
            color: isSelected
                ? const Color(0xFF6B9B6E)
                : const Color(0xFF6B9B6E).withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B9B6E),
          ),
        ),
      ),
    );
  }
}
