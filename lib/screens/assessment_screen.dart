import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/scale_provider.dart';
import '../core/providers/patient_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/patient_model.dart';
import '../core/services/voice_service.dart';
import 'assessment_result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final Patient patient;
  final bool isICUMode;

  const AssessmentScreen({
    super.key,
    required this.patient,
    this.isICUMode = false,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  int? _currentItemIndex;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScaleProvider, PatientProvider>(
      builder: (context, scaleProvider, patientProvider, child) {
        final definition = scaleProvider.currentScaleDefinition;
        
        if (definition == null) {
          return const Scaffold(
            body: Center(child: Text('No scale selected')),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _showCancelConfirmation(context, scaleProvider);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(definition.name),
                  Text(
                    widget.patient.name,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showCancelConfirmation(context, scaleProvider),
              ),
              actions: [
                if (widget.isICUMode)
                  Chip(
                    label: const Text(
                      'ICU Mode',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: AppTheme.warningColor,
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // Progress indicator
                if (!widget.isICUMode) _buildProgressIndicator(scaleProvider, definition),
                
                // Score summary (ICU mode always shows this)
                if (widget.isICUMode || scaleProvider.currentScores.isNotEmpty)
                  _buildScoreSummary(scaleProvider, definition),
                
                // Items list
                Expanded(
                  child: widget.isICUMode
                      ? _buildICUModeList(scaleProvider, definition)
                      : _buildStandardList(scaleProvider, definition),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context, scaleProvider),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(ScaleProvider provider, definition) {
    final totalItems = definition.items.length;
    final completedItems = provider.currentScores.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            '$completedItems of $totalItems items completed',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(ScaleProvider provider, definition) {
    final totalScore = provider.currentTotalScore;
    final severity = provider.currentSeverityLevel;
    final riskColor = severity != null ? AppTheme.getRiskColorFromLevel(severity.riskLevel) : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: riskColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Score',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                Text(
                  '$totalScore / ${definition.maxScore}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
          if (severity != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                severity.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardList(ScaleProvider provider, definition) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: definition.items.length,
      itemBuilder: (context, index) {
        final item = definition.items[index];
        final currentScore = provider.currentScores[item.id];
        final isCompleted = currentScore != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.textHint,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(Icons.check_circle, color: AppTheme.successColor),
                  ],
                ),
                if (item.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.options.map((option) {
                    final isSelected = currentScore == option.value;
                    return ChoiceChip(
                      label: Text(option.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setItemScore(item.id, option.value);
                        }
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildICUModeList(ScaleProvider provider, definition) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: definition.items.length,
      itemBuilder: (context, index) {
        final item = definition.items[index];
        final currentScore = provider.currentScores[item.id] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.question,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Score: $currentScore',
              style: TextStyle(
                color: AppTheme.getRiskColor(currentScore.toDouble(), item.maxScore.toDouble()),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(item.maxScore + 1, (scoreIndex) {
                final isSelected = currentScore == scoreIndex;
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: Material(
                    color: isSelected
                        ? AppTheme.getRiskColor(scoreIndex.toDouble(), item.maxScore.toDouble())
                        : AppTheme.textHint,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => provider.setItemScore(item.id, scoreIndex),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Text(
                          '$scoreIndex',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, ScaleProvider provider) {
    final definition = provider.currentScaleDefinition;
    final allCompleted = definition != null &&
        provider.currentScores.length == definition.items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!widget.isICUMode)
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: _toggleVoiceInput,
                color: _isListening ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: allCompleted
                    ? () => _completeAssessment(context, provider)
                    : null,
                child: const Text('Complete Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleVoiceInput() async {
    setState(() => _isListening = !_isListening);
    
    if (_isListening) {
      // Start voice listening
      _voiceService.startListening(
        onResult: (words) {
          debugPrint('Voice result: $words');
        },
        onComplete: () {
          setState(() => _isListening = false);
        },
      );
    } else {
      _voiceService.stopListening();
    }
  }

  void _showCancelConfirmation(BuildContext context, ScaleProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Assessment'),
        content: const Text('Are you sure you want to cancel? Progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              provider.cancelAssessment();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeAssessment(BuildContext context, ScaleProvider provider) async {
    final assessment = await provider.completeAssessment(widget.patient.id);
    
    if (assessment != null && context.mounted) {
      // Generate AI summary
      await provider.generateAISummary(assessment, widget.patient.diagnosis);
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentResultScreen(
              assessment: assessment,
              patient: widget.patient,
            ),
          ),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.lastError ?? 'Unable to complete assessment. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}