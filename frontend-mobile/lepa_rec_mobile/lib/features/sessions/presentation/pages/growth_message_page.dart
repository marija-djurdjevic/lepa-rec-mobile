import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/primer_flow_state.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../data/dtos/complete_primer_dto.dart';
import '../../data/dtos/growth_message_dto.dart';
import '../../data/repositories/session_repository.dart';

class GrowthMessagePage extends StatefulWidget {
  final VoidCallback onComplete;
  final Function(PrimerFlowState) onStateUpdate;
  final PrimerFlowState primerFlowState;

  const GrowthMessagePage({
    super.key,
    required this.onComplete,
    required this.onStateUpdate,
    required this.primerFlowState,
  });

  @override
  State<GrowthMessagePage> createState() => _GrowthMessagePageState();
}

class _GrowthMessagePageState extends State<GrowthMessagePage> {
  late final SessionRepository _sessionRepository;
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _errorMessage;
  GrowthMessageDto? _growthMessage;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _loadGrowthMessage();
  }

  Future<void> _loadGrowthMessage() async {
    try {
      final message = await _sessionRepository.getRandomGrowthMessage();

      if (!mounted) return;

      setState(() {
        _growthMessage = message;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '${context.l10n.failedLoadGrowthMessage}: $e';
      });
    }
  }

  Future<void> _continueToNextAndCompletePrimer() async {
    if (_growthMessage == null) {
      return;
    }

    setState(() => _isCompleting = true);

    try {
      final updatedState = widget.primerFlowState.copyWith(
        growthMessageId: _growthMessage!.messageId,
      );

      widget.onStateUpdate(updatedState);

      final completePrimerDto = CompletePrimerDto(
        isSkipped: false,
        presentedStatementIds: updatedState.presentedStatementIds,
        selectedStatementId: updatedState.selectedStatementId,
        growthMessageId: updatedState.growthMessageId,
      );

      await _sessionRepository.completePrimerWithData(completePrimerDto);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorCompletingPrimer(e.toString())),
            backgroundColor: Colors.red,
          ),
        );

        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F9F3),
          elevation: 0,
          leading: null,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B9B6E)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F9F3),
          elevation: 0,
          leading: null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorLoadingMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9B6E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadGrowthMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                ),
                child: Text(
                  context.l10n.retry,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9F3),
        elevation: 0,
        leading: null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                context.l10n.growthMessageTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B9B6E),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6B9B6E),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _growthMessage?.text ??
                            context.l10n.loadingPersonalizedMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B9B6E),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCompleting
                      ? null
                      : _continueToNextAndCompletePrimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9B6E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBBBBBB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.l10n.completePrimer,
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
