import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/scoring_engine.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../l10n/app_localizations_ext.dart';
import '../widgets/alert_banner.dart';
import '../voice/speech_service.dart';
import '../voice/model_manager_sheet.dart';

/// Scale assessment screen with full item-by-item scoring.
class ScaleScreen extends StatefulWidget {
  final String patientId;
  final String scaleName;
  final ScaleResult? existingResult;

  const ScaleScreen({
    super.key,
    required this.patientId,
    required this.scaleName,
    this.existingResult,
  });

  @override
  State<ScaleScreen> createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final _db = DatabaseService();
  final _speech = SpeechService();
  late Map<String, int> _scores;
  late List<ScaleItem> _items;
  bool _isSaving = false;
  bool _isListening = false;
  int? _listeningItemIndex;

  @override
  void initState() {
    super.initState();
    _items = ScoringEngine.getItems(widget.scaleName);
    _initScores();
  }

  void _initScores() {
    _scores = {};
    for (final item in _items) {
      _scores[item.key] = widget.existingResult?.itemScores[item.key] ??
          item.minScore;
    }
  }

  int get _totalScore => _scores.values.fold(0, (sum, v) => sum + v);

  String get _severity {
    if (widget.scaleName == AppConstants.scaleCSSRS) {
      return ScoringEngine.cssrsRisk(_scores);
    }
    return ScoringEngine.getSeverity(widget.scaleName, _totalScore);
  }

  String get _riskLevel {
    if (widget.scaleName == AppConstants.scaleCSSRS) {
      return _severity;
    }
    // Derive risk from severity for other scales
    switch (_severity) {
      case AppConstants.severityVerySevere:
        return AppConstants.riskHigh;
      case AppConstants.severitySevere:
        return AppConstants.riskModerate;
      default:
        return AppConstants.riskLow;
    }
  }

  bool get _hasSuicideRisk =>
      widget.scaleName == AppConstants.scaleCSSRS &&
      (_riskLevel == AppConstants.riskHigh ||
          _riskLevel == AppConstants.riskCritical);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsExt.of(context);
    final maxScore = ScoringEngine.getMaxScore(widget.scaleName);
    final progress = maxScore > 0 ? _totalScore / maxScore : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scaleName),
        actions: [
          IconButton(
            icon: const Icon(Icons.memory),
            tooltip: l10n.modelManager,
            onPressed: () => showModelManagerSheet(context),
          ),
          IconButton(
            icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none),
            tooltip: l10n.voiceInput,
            onPressed: _toggleVoice,
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveResult,
            child: Text(l10n.save.toUpperCase(),
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ResponsivePage(
        padding: EdgeInsets.zero,
        child: Column(
        children: [
          // Score header
          _buildScoreHeader(context, _totalScore, maxScore, progress),
          // C-SSRS alert
          if (_hasSuicideRisk)
            AlertBanner(
              riskLevel: _riskLevel,
              message: l10n.suicideRiskDetected,
            ),
          // Scale items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (ctx, i) => _buildItemCard(i, _items[i]),
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveResult,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(l10n.saveAssessment),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context, int score, int maxScore, double progress) {
    final l10n = AppLocalizationsExt.of(context);
    final severityColor = widget.scaleName == AppConstants.scaleCSSRS
        ? AppTheme.riskColor(_severity)
        : AppTheme.severityColor(_severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                maxScore > 0
                    ? l10n.scoreWithMaxLabel(score, maxScore)
                    : l10n.scoreLabel('$score'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                ),
                child: Text(
                  widget.scaleName == AppConstants.scaleCSSRS
                      ? l10n.riskLabel(_severity)
                      : l10n.severityLabel(_severity),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (maxScore > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor:
                  AlwaysStoppedAnimation<Color>(severityColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(int index, ScaleItem item) {
    final currentScore = _scores[item.key] ?? item.minScore;
    final isListeningThis = _isListening && _listeningItemIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.question,
                      style:
                          const TextStyle(fontWeight: FontWeight.w500)),
                ),
                if (isListeningThis)
                  const Icon(Icons.mic, color: Colors.red, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            // Score selector
            if (item.labels.length <= 4)
              _buildButtonSelector(item, currentScore)
            else
              _buildSliderSelector(item, currentScore),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSelector(ScaleItem item, int currentScore) {
    return Wrap(
      spacing: 6,
      children: List.generate(
        item.maxScore - item.minScore + 1,
        (i) {
          final value = item.minScore + i;
          final label = i < item.labels.length ? item.labels[i] : value.toString();
          final isSelected = currentScore == value;
          return ChoiceChip(
            label: Text(label, style: const TextStyle(fontSize: 11)),
            selected: isSelected,
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
                color: isSelected ? Colors.white : null),
            onSelected: (_) => setState(() => _scores[item.key] = value),
          );
        },
      ),
    );
  }

  Widget _buildSliderSelector(ScaleItem item, int currentScore) {
    return Column(
      children: [
        Slider(
          value: currentScore.toDouble(),
          min: item.minScore.toDouble(),
          max: item.maxScore.toDouble(),
          divisions: item.maxScore - item.minScore,
          label: currentScore.toString(),
          activeColor: AppTheme.primaryColor,
          onChanged: (v) => setState(() => _scores[item.key] = v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${item.minScore}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text(
              (currentScore - item.minScore) < item.labels.length
                  ? item.labels[currentScore - item.minScore]
                  : currentScore.toString(),
              style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Text('${item.maxScore}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _speech.stopListening();
      setState(() {
        _isListening = false;
        _listeningItemIndex = null;
      });
    } else if (!_isSaving) {
      setState(() {
        _isListening = true;
        _listeningItemIndex = 0;
      });
      await _speech.startListening(
        onResult: (transcript) {
          final score = SpeechService.parseScore(transcript);
          if (score != null && _listeningItemIndex != null) {
            final item = _items[_listeningItemIndex!];
            if (score >= item.minScore && score <= item.maxScore) {
              setState(() {
                _scores[item.key] = score;
                if (_listeningItemIndex! < _items.length - 1) {
                  _listeningItemIndex = _listeningItemIndex! + 1;
                } else {
                  _isListening = false;
                  _listeningItemIndex = null;
                }
              });
            }
          }
        },
        onError: (error) {
          setState(() {
            _isListening = false;
            _listeningItemIndex = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice input unavailable: $error')),
            );
          }
        },
      );
    }
  }

  Future<void> _saveResult() async {
    final l10n = AppLocalizationsExt.of(context);
    setState(() => _isSaving = true);
    final result = ScaleResult(
      patientId: widget.patientId,
      scaleName: widget.scaleName,
      totalScore: _totalScore,
      severity: _severity,
      riskLevel: _riskLevel,
      itemScores: Map.from(_scores),
    );
    try {
      await _db.insertScaleResult(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.savedAssessmentSnack(
            widget.scaleName,
            _totalScore,
            widget.scaleName == AppConstants.scaleCSSRS
                ? l10n.riskLabel(_severity)
                : l10n.severityLabel(_severity),
          )),
          backgroundColor: AppTheme.successColor,
        ));
        if (_hasSuicideRisk) {
          showAlertDialog(context, result);
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save assessment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void showAlertDialog(BuildContext context, ScaleResult result) {
    final l10n = AppLocalizationsExt.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.dangerColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.suicideRiskAlertTitle,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cssrsRiskLevel(l10n.riskLabel(result.riskLevel)),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.suicideProtocolBullets,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(l10n.acknowledged,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
