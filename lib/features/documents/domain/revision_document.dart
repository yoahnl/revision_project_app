class RevisionDocument {
  const RevisionDocument({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.fileName,
    required this.status,
    required this.mimeType,
    this.errorCode,
  });

  final String id;
  final String subjectId;
  final String kind;
  final String fileName;
  final String status;
  final String mimeType;
  final String? errorCode;
}

class DocumentKnowledgeUnitSource {
  const DocumentKnowledgeUnitSource({
    required this.chunkId,
    required this.text,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final String text;
  final int? pageNumber;
  final int index;
}

class DocumentKnowledgeUnit {
  const DocumentKnowledgeUnit({
    required this.id,
    required this.title,
    required this.summary,
    required this.sources,
    this.difficulty,
    this.displayOrder,
    this.confidence,
  });

  final String id;
  final String title;
  final String summary;
  final String? difficulty;
  final int? displayOrder;
  final double? confidence;
  final List<DocumentKnowledgeUnitSource> sources;
}

class DocumentKnowledgeUnitsResponse {
  const DocumentKnowledgeUnitsResponse({
    required this.documentId,
    required this.items,
  });

  final String documentId;
  final List<DocumentKnowledgeUnit> items;
}

class DocumentArtifactSource {
  const DocumentArtifactSource({
    required this.chunkId,
    required this.text,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final String text;
  final int? pageNumber;
  final int index;
}

class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.documentId,
    required this.subjectId,
    required this.status,
    required this.title,
    required this.content,
    required this.keyPoints,
    required this.limits,
    required this.errorCode,
    required this.sources,
  });

  final String id;
  final String documentId;
  final String subjectId;
  final String status;
  final String title;
  final String content;
  final List<String> keyPoints;
  final String? limits;
  final String? errorCode;
  final List<DocumentArtifactSource> sources;
}

class RevisionSheet {
  const RevisionSheet({
    required this.id,
    required this.documentId,
    required this.subjectId,
    required this.status,
    required this.title,
    required this.introduction,
    required this.sections,
    required this.keyPoints,
    required this.commonMistakes,
    required this.mustKnow,
    required this.practiceSuggestions,
    required this.errorCode,
  });

  final String id;
  final String documentId;
  final String subjectId;
  final String status;
  final String title;
  final String? introduction;
  final List<RevisionSheetSection> sections;
  final List<String> keyPoints;
  final List<String> commonMistakes;
  final List<String> mustKnow;
  final List<String> practiceSuggestions;
  final String? errorCode;
}

class RevisionSheetSection {
  const RevisionSheetSection({
    required this.id,
    required this.displayOrder,
    required this.title,
    required this.content,
    required this.sources,
  });

  final String id;
  final int displayOrder;
  final String title;
  final String content;
  final List<DocumentArtifactSource> sources;
}
