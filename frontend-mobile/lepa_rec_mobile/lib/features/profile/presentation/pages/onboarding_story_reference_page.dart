import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/core/widgets/app_top_bar.dart';

class OnboardingStoryReferencePage extends StatelessWidget {
  const OnboardingStoryReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      context.l10n.onboardingStoryHook,
      context.l10n.onboardingStorySkill,
      context.l10n.onboardingStoryHabit,
    ];

    return Scaffold(
      appBar: AppTopBar(title: context.l10n.onboardingStoryReferenceTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            for (var i = 0; i < messages.length; i++) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B9B6E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i != messages.length - 1)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                color: const Color(0xFFD9E5D7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: i == messages.length - 1 ? 0 : AppSpacing.lg,
                        ),
                        child: Text(
                          messages[i],
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F4C45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
