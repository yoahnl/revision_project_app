import 'package:flutter/material.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';

class SubjectDocumentListItem extends StatelessWidget {
  const SubjectDocumentListItem({
    required this.document,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final RevisionDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final (:label, :color) = _documentStatus(document);

    return RevisionSourceFileCard(
      fileName: document.fileName,
      statusLabel: '${_documentKindLabel(document.kind)} · $label',
      statusColor: color,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: RevisionColors.textMuted,
            ),
            tooltip: 'Supprimer la source',
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

({String label, Color color}) _documentStatus(RevisionDocument document) {
  return switch (document.status) {
    'UPLOADED' => (label: 'Importée', color: RevisionColors.cyan),
    'PROCESSING' => (label: 'En analyse', color: RevisionColors.violet),
    'READY' => (label: 'Prête', color: RevisionColors.green),
    'FAILED' => (
      label: _failedDocumentLabel(document.errorCode),
      color: RevisionColors.red,
    ),
    _ => (label: document.status, color: RevisionColors.textMuted),
  };
}

String _failedDocumentLabel(String? errorCode) {
  return switch (errorCode) {
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte',
    'DOCUMENT_TEXT_EXTRACTION_FAILED' => 'Lecture PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion',
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Erreur IA',
    'DOCUMENT_UNSUPPORTED_MIME_TYPE' => 'Format invalide',
    _ => 'Échec',
  };
}

String _documentKindLabel(String kind) {
  return switch (kind) {
    'COURSE_PDF' => 'PDF de cours',
    'EXAM_PDF' => 'PDF examen',
    'EXAM_IMAGE' => 'Image examen',
    _ => kind,
  };
}
