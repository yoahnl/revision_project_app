class RevisionDocument {
  const RevisionDocument({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.fileName,
    required this.status,
    required this.mimeType,
  });

  final String id;
  final String subjectId;
  final String kind;
  final String fileName;
  final String status;
  final String mimeType;
}
