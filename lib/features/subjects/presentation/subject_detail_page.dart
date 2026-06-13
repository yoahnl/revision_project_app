import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../documents/application/documents_controller.dart';
import '../../documents/domain/revision_document.dart';
import '../../documents/presentation/document_import_button.dart';
import '../application/subjects_controller.dart';
import '../domain/subject.dart';

class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({
    required this.subjectId,
    required this.controller,
    required this.documentsController,
    super.key,
  });

  final String subjectId;
  final SubjectsController controller;
  final DocumentsController documentsController;

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late Future<_SubjectDetailData> _detailData;

  @override
  void initState() {
    super.initState();
    _detailData = _loadDetailData();
  }

  void _reloadSubject() {
    setState(() {
      _detailData = _loadDetailData();
    });
  }

  Future<_SubjectDetailData> _loadDetailData() async {
    final subject = await widget.controller.getSubject(widget.subjectId);
    final documents = await widget.documentsController.listSubjectDocuments(
      widget.subjectId,
    );

    return _SubjectDetailData(subject: subject, documents: documents);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SubjectDetailData>(
      future: _detailData,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError || data == null) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Impossible de charger la matiere',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _reloadSubject,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reessayer'),
                ),
              ),
            ],
          );
        }

        final subject = data.subject;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              subject.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Priorite ${subject.priority}'),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => context.go(
                  Uri(
                    path: activitiesRoutePath,
                    queryParameters: {'subjectId': widget.subjectId},
                  ).toString(),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Lancer un diagnostic'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cours',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _reloadSubject,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recharger',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: DocumentImportButton(
                subjectId: widget.subjectId,
                controller: widget.documentsController,
                onImported: _reloadSubject,
              ),
            ),
            const SizedBox(height: 16),
            if (data.documents.isEmpty)
              const Text('Aucun cours importe')
            else
              for (final document in data.documents)
                _DocumentListItem(document: document),
          ],
        );
      },
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  const _DocumentListItem({required this.document});

  final RevisionDocument document;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.picture_as_pdf_outlined),
      title: Text(document.fileName),
      subtitle: Text(_documentKindLabel(document.kind)),
      trailing: _DocumentStatusChip(
        status: document.status,
        errorCode: document.errorCode,
      ),
    );
  }
}

class _DocumentStatusChip extends StatelessWidget {
  const _DocumentStatusChip({required this.status, this.errorCode});

  final String status;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (:label, :color) = switch (status) {
      'UPLOADED' => (label: 'Importe', color: colorScheme.secondary),
      'PROCESSING' => (label: 'Analyse', color: colorScheme.primary),
      'READY' => (label: 'Pret', color: colorScheme.tertiary),
      'FAILED' => (
        label: _failedDocumentLabel(errorCode),
        color: colorScheme.error,
      ),
      _ => (label: status, color: colorScheme.outline),
    };

    return Chip(
      label: Text(label),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
    );
  }
}

String _failedDocumentLabel(String? errorCode) {
  return switch (errorCode) {
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte',
    'DOCUMENT_TEXT_EXTRACTION_FAILED' => 'Lecture PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion',
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Erreur IA',
    'DOCUMENT_UNSUPPORTED_MIME_TYPE' => 'Format invalide',
    _ => 'Echec',
  };
}

class _SubjectDetailData {
  const _SubjectDetailData({required this.subject, required this.documents});

  final Subject subject;
  final List<RevisionDocument> documents;
}

String _documentKindLabel(String kind) {
  return switch (kind) {
    'COURSE_PDF' => 'PDF de cours',
    'EXAM_PDF' => 'PDF examen',
    'EXAM_IMAGE' => 'Image examen',
    _ => kind,
  };
}
