import '../../../documents/domain/revision_document.dart';
import '../../domain/course_models.dart';

class SourceDisplayLabel {
  const SourceDisplayLabel({
    required this.primary,
    required this.originalFileName,
  });

  final String primary;
  final String? originalFileName;

  String? get originalFileLine {
    final original = originalFileName?.trim();
    if (original == null || original.isEmpty) {
      return null;
    }

    return 'Fichier original : $original';
  }
}

SourceDisplayLabel sourceDisplayLabelForCourseDocument(
  CourseDocument document, {
  int? index,
}) {
  return sourceDisplayLabelForFileName(document.fileName, index: index);
}

SourceDisplayLabel sourceDisplayLabelForRevisionDocument(
  RevisionDocument document, {
  int? index,
}) {
  return sourceDisplayLabelForFileName(document.fileName, index: index);
}

SourceDisplayLabel sourceDisplayLabelForFileName(
  String fileName, {
  int? index,
  String fallbackPrimary = 'Document du cours',
}) {
  final original = fileName.trim();
  final fallback = _fallbackSupportLabel(index, fallbackPrimary);
  if (original.isEmpty) {
    return SourceDisplayLabel(primary: fallback, originalFileName: null);
  }

  final basename = _basename(original);
  final stem = _stripKnownExtension(basename);
  final cleanedStem = _stripTechnicalPrefix(stem);
  final supportNumber = _supportNumber(cleanedStem);
  if (supportNumber != null) {
    return SourceDisplayLabel(
      primary: 'Support $supportNumber',
      originalFileName: original,
    );
  }

  if (_isTechnicalStem(cleanedStem)) {
    return SourceDisplayLabel(primary: fallback, originalFileName: original);
  }

  return SourceDisplayLabel(
    primary: _titleCaseSource(cleanedStem),
    originalFileName: original,
  );
}

SourceDisplayLabel humanSourceTitle({
  required String? title,
  required String fileName,
  int? index,
}) {
  final candidate = title?.trim();
  if (candidate != null &&
      candidate.isNotEmpty &&
      !_looksTechnical(candidate) &&
      !_containsForbiddenUserToken(candidate)) {
    return SourceDisplayLabel(
      primary: _titleCaseSource(candidate),
      originalFileName: fileName.trim().isEmpty ? null : fileName.trim(),
    );
  }

  return sourceDisplayLabelForFileName(fileName, index: index);
}

String humanLearningPathNodeTitle(CourseLearningPathNode node, {int? index}) {
  final displayTitle = node.display.title.trim();
  if (displayTitle.isNotEmpty &&
      !_looksTechnical(displayTitle) &&
      !_containsForbiddenUserToken(displayTitle)) {
    return displayTitle;
  }

  final title = node.title.trim();
  if (title.isNotEmpty &&
      !_looksTechnical(title) &&
      !_containsForbiddenUserToken(title)) {
    return title;
  }

  final sourceFileName = node.source?.fileName;
  if (sourceFileName != null && sourceFileName.trim().isNotEmpty) {
    return sourceDisplayLabelForFileName(sourceFileName, index: index).primary;
  }

  return index == null ? 'Notion du cours' : 'Notion ${index + 1}';
}

String humanSourceLabelText(String value, {int? index}) {
  return humanSourceTitle(title: value, fileName: value, index: index).primary;
}

String _fallbackSupportLabel(int? index, String fallbackPrimary) {
  if (index == null) {
    return fallbackPrimary;
  }

  return 'Support ${index + 1}';
}

String _basename(String value) {
  final normalized = value.replaceAll('\\', '/');
  final withoutQuery = normalized.split('?').first.split('#').first;
  final segments = withoutQuery.split('/');
  return segments.isEmpty ? withoutQuery.trim() : segments.last.trim();
}

String _stripKnownExtension(String value) {
  return value.replaceFirst(
    RegExp(r'\.(pdf|docx?|pptx?|txt|md)$', caseSensitive: false),
    '',
  );
}

String _stripTechnicalPrefix(String value) {
  var result = value.trim();
  final patterns = [
    RegExp(r'^[0-9]{10,}[\s_-]+'),
    RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}[\s_-]*',
      caseSensitive: false,
    ),
    RegExp(r'^[0-9a-f]{16,}[\s_-]+', caseSensitive: false),
  ];

  var changed = true;
  while (changed) {
    changed = false;
    for (final pattern in patterns) {
      final next = result.replaceFirst(pattern, '').trim();
      if (next != result) {
        result = next;
        changed = true;
      }
    }
  }

  return result;
}

int? _supportNumber(String value) {
  final match = RegExp(
    r'^(support|source|document|doc|file)[\s_-]*0*([1-9][0-9]*)$',
    caseSensitive: false,
  ).firstMatch(value.trim());

  if (match == null) {
    return null;
  }

  return int.tryParse(match.group(2)!);
}

bool _looksTechnical(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }

  if (_containsForbiddenUserToken(trimmed)) {
    return true;
  }

  final basename = _basename(trimmed);
  final hasKnownExtension = RegExp(
    r'\.(pdf|docx?|pptx?|txt|md)$',
    caseSensitive: false,
  ).hasMatch(basename);
  if (hasKnownExtension) {
    return true;
  }

  final stem = _stripTechnicalPrefix(_stripKnownExtension(basename));
  return _supportNumber(stem) != null || _isTechnicalStem(stem);
}

bool _containsForbiddenUserToken(String value) {
  final lower = value.toLowerCase();
  const forbidden = [
    'backend',
    'payload',
    'documentid',
    'sourceid',
    'chunkid',
    'uuid',
    'legacy',
    'genui',
    'prisma',
  ];

  return forbidden.any(lower.contains);
}

bool _isTechnicalStem(String value) {
  final normalized = _normalizeTokens(value);
  if (normalized.isEmpty) {
    return true;
  }

  if (RegExp(r'^[0-9]{6,}$').hasMatch(normalized)) {
    return true;
  }

  if (RegExp(r'^[0-9a-f]{12,}$', caseSensitive: false).hasMatch(normalized)) {
    return true;
  }

  if (RegExp(
    r'^(img|image|scan|screenshot|photo)[\s_-]*[0-9]+$',
    caseSensitive: false,
  ).hasMatch(value.trim())) {
    return true;
  }

  final words = normalized.split(' ');
  if (words.length == 1 && _genericSourceWords.contains(words.single)) {
    return true;
  }

  return words.every((word) {
    return _genericSourceWords.contains(word) ||
        RegExp(r'^v?[0-9]+$').hasMatch(word);
  });
}

String _normalizeTokens(String value) {
  return value
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}

String _titleCaseSource(String value) {
  final normalized = _normalizeTokens(value);
  if (normalized.isEmpty) {
    return 'Document du cours';
  }

  final words = normalized.split(' ');
  final transformed = <String>[];
  for (final (index, word) in words.indexed) {
    if (word.isEmpty) {
      continue;
    }

    if (RegExp(r'^[0-9]+$').hasMatch(word)) {
      transformed.add(word);
      continue;
    }

    if (index == 0) {
      transformed.add('${word[0].toUpperCase()}${word.substring(1)}');
    } else {
      transformed.add(word);
    }
  }

  return transformed.join(' ');
}

const _genericSourceWords = {
  'cm',
  'cours',
  'course',
  'doc',
  'document',
  'file',
  'fichier',
  'final',
  'img',
  'image',
  'pdf',
  'scan',
  'source',
  'support',
  'upload',
  'uploaded',
  'version',
};
