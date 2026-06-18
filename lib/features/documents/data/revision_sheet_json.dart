import '../domain/revision_document.dart';

class RevisionSheetJson {
  const RevisionSheetJson(this.value);

  final Object? value;

  RevisionSheet toRevisionSheet() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final introduction = json['introduction'];
    final sections = json['sections'];
    final keyPoints = json['keyPoints'];
    final commonMistakes = json['commonMistakes'];
    final mustKnow = json['mustKnow'];
    final practiceSuggestions = json['practiceSuggestions'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        (introduction != null && introduction is! String) ||
        sections is! List ||
        keyPoints is! List ||
        commonMistakes is! List ||
        mustKnow is! List ||
        practiceSuggestions is! List ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid revision sheet response');
    }

    return RevisionSheet(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      introduction: introduction as String?,
      sections: sections
          .map((section) => _RevisionSheetSectionJson(section).toSection())
          .toList(growable: false),
      keyPoints: _stringList(keyPoints, 'Invalid revision sheet response'),
      commonMistakes: _stringList(
        commonMistakes,
        'Invalid revision sheet response',
      ),
      mustKnow: _stringList(mustKnow, 'Invalid revision sheet response'),
      practiceSuggestions: _stringList(
        practiceSuggestions,
        'Invalid revision sheet response',
      ),
      errorCode: errorCode as String?,
    );
  }
}

class _RevisionSheetSectionJson {
  const _RevisionSheetSectionJson(this.value);

  final Object? value;

  RevisionSheetSection toSection() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet section response');
    }

    final id = json['id'];
    final displayOrder = json['displayOrder'];
    final title = json['title'];
    final content = json['content'];
    final sources = json['sources'];

    if (id is! String ||
        displayOrder is! int ||
        title is! String ||
        content is! String ||
        sources is! List) {
      throw const FormatException('Invalid revision sheet section response');
    }

    return RevisionSheetSection(
      id: id,
      displayOrder: displayOrder,
      title: title,
      content: content,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _DocumentArtifactSourceJson {
  const _DocumentArtifactSourceJson(this.value);

  final Object? value;

  DocumentArtifactSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid artifact source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid artifact source response');
    }

    return DocumentArtifactSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

List<String> _stringList(List value, String message) {
  if (value.any((item) => item is! String)) {
    throw FormatException(message);
  }

  return value.cast<String>().toList(growable: false);
}
