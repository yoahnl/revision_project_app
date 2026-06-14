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
