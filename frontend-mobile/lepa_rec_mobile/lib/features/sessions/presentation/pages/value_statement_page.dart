import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/primer_flow_state.dart';

import '../../../../core/constants/app_spacing.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/dtos/primer_statement_dto.dart';
import '../../data/repositories/session_repository.dart';

class ValueStatementPage extends StatefulWidget {
  final VoidCallback onComplete;
  final Function(PrimerFlowState) onStateUpdate;
  final PrimerFlowState primerFlowState;

  const ValueStatementPage({
    super.key,
    required this.onComplete,
    required this.onStateUpdate,
    required this.primerFlowState,
  });

  @override
  State<ValueStatementPage> createState() => _ValueStatementPageState();
}

class _ValueStatementPageState extends State<ValueStatementPage> {
  late final SessionRepository _sessionRepository;
  bool _isLoading = true;
  String? _errorMessage;
  List<PrimerStatementDto> _statements = [];
  String? _selectedStatementId;
  String? _activePracticeLang;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = _currentPracticeLang();
    if (_activePracticeLang == currentLang) return;
    _activePracticeLang = currentLang;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadStatements();
  }

  Future<void> _loadStatements() async {
    try {
      final statements = await _sessionRepository.getRandomPrimerStatements(
        lang: _currentPracticeLang(),
      );

      if (!mounted) return;

      setState(() {
        _statements = statements;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '${context.l10n.failedLoadValueStatements}: $e';
      });
    }
  }

  void _selectValue(PrimerStatementDto statement) {
    setState(() {
      _selectedStatementId = statement.statementId;
    });

    final statementIds = _statements.map((s) => s.statementId).toList();

    final updatedState = widget.primerFlowState.copyWith(
      presentedStatementIds: statementIds,
      selectedStatementId: statement.statementId,
    );

    widget.onStateUpdate(updatedState);

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F3),
        appBar: AppTopBar(
          title: context.l10n.dailySession,
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
        appBar: AppTopBar(
          title: context.l10n.dailySession,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorLoadingStatements,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9B6E),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadStatements();
                },
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dailySession,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                context.l10n.valueStatementTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B9B6E),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _statements
                      .map((statement) => _buildStatementButton(statement))
                      .toList()
                      .fold<List<Widget>>([], (acc, widget) {
                        acc.add(widget);
                        if (acc.length < _statements.length * 2) {
                          acc.add(const SizedBox(height: AppSpacing.md));
                        }
                        return acc;
                      }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementButton(PrimerStatementDto statement) {
    final isSelected = _selectedStatementId == statement.statementId;

    return ElevatedButton(
      onPressed: () => _selectValue(statement),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        backgroundColor: isSelected
            ? const Color(0xFF6B9B6E).withValues(alpha: 0.85)
            : const Color(0xFF6B9B6E).withValues(alpha: 0.25),
        foregroundColor: isSelected ? Colors.white : const Color(0xFF6B9B6E),
        elevation: isSelected ? 3 : 1,
        shadowColor: const Color(0xFF6B9B6E).withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF6B9B6E),
            width: isSelected ? 2 : 1.5,
          ),
        ),
      ),
      child: Text(
        statement.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF6B9B6E),
        ),
      ),
    );
  }

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
  }
}

