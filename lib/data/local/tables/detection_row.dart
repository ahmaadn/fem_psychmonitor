import 'dart:convert';

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';

/// Row ⇄ model mappers for `detection_sessions` and `detection_results`.
class DetectionSessionRow {
  DetectionSessionRow._();

  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colStartedAt = 'started_at';
  static const String colStoppedAt = 'stopped_at';
  static const String colSourceType = 'source_type';
  static const String colAudioFilePath = 'audio_file_path';
  static const String colDominantEmotion = 'dominant_emotion';
  static const String colDominantConfidence = 'dominant_confidence';
  static const String colNote = 'note';
  static const String colCorrectedEmotion = 'corrected_emotion';
  static const String colSelfReportEmotion = 'self_report_emotion';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsDirty = 'is_dirty';

  static Map<String, Object?> toRow(
    DetectionSessionModel session, {
    int? createdAt,
    int? updatedAt,
    bool isDirty = true,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      colId: session.id,
      colUserId: session.userId,
      colStartedAt: session.startedAt.millisecondsSinceEpoch,
      colStoppedAt: session.stoppedAt.millisecondsSinceEpoch,
      colSourceType: session.sourceType.name,
      colAudioFilePath: session.audioFilePath,
      colDominantEmotion: session.dominantEmotion.name,
      colDominantConfidence: session.dominantConfidence,
      colNote: session.note,
      colCorrectedEmotion: session.correctedEmotion?.name,
      colSelfReportEmotion: session.selfReportEmotion?.name,
      colCreatedAt: createdAt ?? now,
      colUpdatedAt: updatedAt ?? now,
      colIsDirty: isDirty ? 1 : 0,
    };
  }

  static DetectionSessionModel toModel(
    Map<String, Object?> row, {
    List<DetectionResultModel> results = const [],
  }) {
    return DetectionSessionModel(
      id: row[colId] as String,
      userId: row[colUserId] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row[colStartedAt] as int),
      stoppedAt:
          DateTime.fromMillisecondsSinceEpoch(row[colStoppedAt] as int),
      sourceType: DetectionSourceType.values.firstWhere(
        (e) => e.name == row[colSourceType],
        orElse: () => DetectionSourceType.live,
      ),
      audioFilePath: row[colAudioFilePath] as String?,
      dominantEmotion: EmotionLabelType.values.firstWhere(
        (e) => e.name == row[colDominantEmotion],
        orElse: () => EmotionLabelType.neutral,
      ),
      dominantConfidence: (row[colDominantConfidence] as num).toDouble(),
      note: row[colNote] as String?,
      correctedEmotion: row[colCorrectedEmotion] == null
          ? null
          : EmotionLabelType.values.firstWhere(
              (e) => e.name == row[colCorrectedEmotion],
              orElse: () => EmotionLabelType.neutral,
            ),
      selfReportEmotion: row[colSelfReportEmotion] == null
          ? null
          : EmotionLabelType.values.firstWhere(
              (e) => e.name == row[colSelfReportEmotion],
              orElse: () => EmotionLabelType.neutral,
            ),
      results: results,
    );
  }
}

class DetectionResultRow {
  DetectionResultRow._();

  static const String colId = 'id';
  static const String colSessionId = 'session_id';
  static const String colStartSec = 'start_sec';
  static const String colEndSec = 'end_sec';
  static const String colLabel = 'label';
  static const String colConfidence = 'confidence';
  static const String colAllProbs = 'all_probs';

  static Map<String, Object?> toRow(DetectionResultModel result) {
    return {
      colId: result.id,
      colSessionId: result.sessionId,
      colStartSec: result.startSec,
      colEndSec: result.endSec,
      colLabel: result.label.name,
      colConfidence: result.confidence,
      colAllProbs: jsonEncode(result.allProbs),
    };
  }

  static DetectionResultModel toModel(Map<String, Object?> row) {
    return DetectionResultModel(
      id: row[colId] as String,
      sessionId: row[colSessionId] as String,
      startSec: (row[colStartSec] as num).toDouble(),
      endSec: (row[colEndSec] as num).toDouble(),
      label: EmotionLabelType.values.firstWhere(
        (e) => e.name == row[colLabel],
        orElse: () => EmotionLabelType.neutral,
      ),
      confidence: (row[colConfidence] as num).toDouble(),
      allProbs: (jsonDecode(row[colAllProbs] as String) as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
