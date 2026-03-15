import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../data/models/primer_statement_dto.dart';
import '../../data/repositories/session_repository.dart';
import '../models/primer_flow_state.dart';

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

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _loadStatements();
  }

  Future<void> _loadStatements() async {
    try {
      final statements = await _sessionRepository.getRandomPrimerStatements();

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
                context.l10n.errorLoadingStatements,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9B6E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_errorMessage',
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9F3),
        elevation: 0,
        leading: null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _statements
                      .map((statement) => _buildStatementButton(statement))
                      .toList()
                      .fold<List<Widget>>([], (acc, widget) {
                    acc.add(widget);
                    if (acc.length < _statements.length * 2) {
                      acc.add(const SizedBox(height: 16));
                    }
                    return acc;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        backgroundColor: isSelected ? const Color(0xFF6B9B6E) : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : const Color(0xFF6B9B6E),
        elevation: isSelected ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF6B9B6E),
            width: 1.5,
          ),
        ),
      ),
      child: Text(
        statement.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF6B9B6E),
        ),
      ),
    );
  }
}

