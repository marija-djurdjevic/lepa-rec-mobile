import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';

class PrimerWelcomePage extends StatelessWidget {
  final VoidCallback onProceed;

  const PrimerWelcomePage({
    super.key,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.primerWelcomeTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B9B6E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      context.l10n.primerWelcomeDescription,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onProceed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.proceed,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
