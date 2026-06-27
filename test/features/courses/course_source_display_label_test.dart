import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/presentation/utils/course_source_display_label.dart';

void main() {
  group('sourceDisplayLabelForFileName', () {
    test('turns timestamped support filenames into neutral support labels', () {
      final label = sourceDisplayLabelForFileName(
        '1782570835662-support01.pdf',
        index: 0,
      );

      expect(label.primary, 'Support 1');
      expect(label.originalFileName, '1782570835662-support01.pdf');
      expect(
        label.originalFileLine,
        'Fichier original : 1782570835662-support01.pdf',
      );
      expect(label.primary, isNot(contains('.pdf')));
      expect(label.primary, isNot(contains('1782570835662')));
    });

    test('keeps exploitable clean filenames without their extension', () {
      final label = sourceDisplayLabelForFileName('intro-droit.pdf');

      expect(label.primary, 'Intro droit');
      expect(label.originalFileLine, 'Fichier original : intro-droit.pdf');
    });

    test('does not promote camera or upload filenames as titles', () {
      expect(
        sourceDisplayLabelForFileName('IMG_1234.pdf', index: 1).primary,
        'Support 2',
      );
      expect(
        sourceDisplayLabelForFileName('document_final_v3_upload.pdf').primary,
        'Document du cours',
      );
    });

    test('supports stable labels for several documents', () {
      expect(
        sourceDisplayLabelForFileName('support01.pdf', index: 0).primary,
        'Support 1',
      );
      expect(
        sourceDisplayLabelForFileName('support02.pdf', index: 1).primary,
        'Support 2',
      );
    });
  });

  group('humanSourceTitle', () {
    test('uses an existing human title before deriving from the filename', () {
      final label = humanSourceTitle(
        title: 'Contrôle de constitutionnalité',
        fileName: '1782570835662-support01.pdf',
        index: 0,
      );

      expect(label.primary, 'Contrôle de constitutionnalité');
      expect(
        label.originalFileLine,
        'Fichier original : 1782570835662-support01.pdf',
      );
    });

    test(
      'rejects technical titles and falls back to a neutral source label',
      () {
        final label = humanSourceTitle(
          title: '1782570835662-support01.pdf',
          fileName: '1782570835662-support01.pdf',
          index: 0,
        );

        expect(label.primary, 'Support 1');
        expect(label.primary, isNot(contains('.pdf')));
      },
    );
  });
}
