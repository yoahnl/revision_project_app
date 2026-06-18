import 'package:flutter/material.dart';

import '../../../presentation/design_system/tokens/revision_colors.dart';

enum MvpRevisionMode { quick, deep, exam }

extension MvpRevisionModeLabel on MvpRevisionMode {
  String get label {
    return switch (this) {
      MvpRevisionMode.quick => 'Rapide',
      MvpRevisionMode.deep => 'Complète',
      MvpRevisionMode.exam => 'Examen',
    };
  }

  String get sessionTitle {
    return switch (this) {
      MvpRevisionMode.quick => 'Révision rapide',
      MvpRevisionMode.deep => 'Révision approfondie',
      MvpRevisionMode.exam => 'Préparation examen',
    };
  }
}

class MvpSubject {
  const MvpSubject({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.courses,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final List<MvpCourse> courses;
}

class MvpCourse {
  const MvpCourse({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.chapterLabel,
    required this.description,
    required this.icon,
    required this.accent,
    required this.completedLessons,
    required this.totalLessons,
    required this.durationMinutes,
    required this.difficulty,
    required this.mastery,
    required this.sources,
    required this.learnItems,
    required this.keyPoints,
    required this.commonMistakes,
    required this.weakSpot,
  });

  final String id;
  final String subjectId;
  final String title;
  final String chapterLabel;
  final String description;
  final IconData icon;
  final Color accent;
  final int completedLessons;
  final int totalLessons;
  final int durationMinutes;
  final String difficulty;
  final double mastery;
  final List<MvpSourceFile> sources;
  final List<String> learnItems;
  final List<String> keyPoints;
  final List<String> commonMistakes;
  final String weakSpot;

  double get progress => completedLessons / totalLessons;

  String get progressLabel => '$completedLessons/$totalLessons leçons';
}

class MvpSourceFile {
  const MvpSourceFile({
    required this.fileName,
    required this.sizeLabel,
    required this.statusLabel,
  });

  final String fileName;
  final String sizeLabel;
  final String statusLabel;
}

class MvpSessionQuestion {
  const MvpSessionQuestion({
    required this.prompt,
    required this.choices,
    required this.correctChoice,
  });

  final String prompt;
  final List<String> choices;
  final String correctChoice;
}

const mvpSessionQuestions = [
  MvpSessionQuestion(
    prompt:
        'Soit X ~ N(0, 1). Quelle est la probabilité que X soit comprise entre -1 et 1 ?',
    choices: ['0,3413', '0,6826', '0,9545', '0,2718'],
    correctChoice: '0,6826',
  ),
  MvpSessionQuestion(
    prompt:
        'Quel réflexe permet de comparer une valeur à une loi normale centrée réduite ?',
    choices: [
      'Standardiser avec Z',
      'Changer la moyenne',
      'Ignorer l’écart-type',
      'Arrondir la probabilité',
    ],
    correctChoice: 'Standardiser avec Z',
  ),
];

final mvpSubjects = [
  MvpSubject(
    id: 'math',
    name: 'Math',
    subtitle: 'Continue ton progrès',
    accent: RevisionColors.mathAccent,
    icon: Icons.calculate_rounded,
    courses: [
      MvpCourse(
        id: 'loi-normale',
        subjectId: 'math',
        title: 'Loi normale',
        chapterLabel: 'Chapitre 3',
        description:
            'Comprendre la loi normale, ses propriétés et son utilisation en statistique inférentielle.',
        icon: Icons.show_chart_rounded,
        accent: RevisionColors.blue,
        completedLessons: 3,
        totalLessons: 7,
        durationMinutes: 20,
        difficulty: 'Intermédiaire',
        mastery: 0.43,
        sources: [
          MvpSourceFile(
            fileName: 'Cours_stats_S1.pdf',
            sizeLabel: '2,4 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'TD_loi_normale.pdf',
            sizeLabel: '1,8 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'notes_chapitre_3.pdf',
            sizeLabel: '3,3 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Comprendre la courbe de la loi normale',
          'Utiliser la loi normale pour des calculs de probabilités',
        ],
        keyPoints: [
          'Courbe symétrique autour de μ',
          '68% des valeurs dans [μ − σ, μ + σ]',
          '95% des valeurs dans [μ − 2σ, μ + 2σ]',
          'Standardisation : Z = (X − μ) / σ ~ N(0, 1)',
        ],
        commonMistakes: [
          'Confondre variance σ² et écart-type σ',
          'Oublier de standardiser avant d’utiliser les tables',
          'Interpréter une probabilité en % sans vérifier l’intervalle',
        ],
        weakSpot: 'Temps estimé et calculs',
      ),
      MvpCourse(
        id: 'bases-statistiques',
        subjectId: 'math',
        title: 'Bases des statistiques',
        chapterLabel: 'Chapitre 2',
        description:
            'Moyenne, médiane, dispersion et lecture rapide des séries.',
        icon: Icons.pie_chart_rounded,
        accent: RevisionColors.mint,
        completedLessons: 2,
        totalLessons: 6,
        durationMinutes: 18,
        difficulty: 'Facile',
        mastery: 0.33,
        sources: [
          MvpSourceFile(
            fileName: 'stats_intro.pdf',
            sizeLabel: '1,6 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'exercices_stats.pdf',
            sizeLabel: '900 Ko',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Lire une série statistique', 'Identifier une dispersion'],
        keyPoints: ['Moyenne sensible aux valeurs extrêmes', 'Médiane robuste'],
        commonMistakes: ['Comparer deux séries sans regarder la dispersion'],
        weakSpot: 'Lecture des écarts',
      ),
      MvpCourse(
        id: 'algebre-lineaire',
        subjectId: 'math',
        title: 'Algèbre linéaire',
        chapterLabel: 'Chapitre 5',
        description: 'Matrices, vecteurs et transformations linéaires.',
        icon: Icons.view_in_ar_rounded,
        accent: RevisionColors.violet,
        completedLessons: 4,
        totalLessons: 8,
        durationMinutes: 25,
        difficulty: 'Intermédiaire',
        mastery: 0.50,
        sources: [
          MvpSourceFile(
            fileName: 'algebre_matrices.pdf',
            sizeLabel: '3,0 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Manipuler les matrices', 'Lire une transformation'],
        keyPoints: [
          'Produit matriciel non commutatif',
          'Le rang mesure l’information',
        ],
        commonMistakes: ['Inverser les dimensions dans un produit'],
        weakSpot: 'Produit matriciel',
      ),
      MvpCourse(
        id: 'probabilites',
        subjectId: 'math',
        title: 'Probabilités',
        chapterLabel: 'Chapitre 6',
        description: 'Evénements, indépendance et variables aléatoires.',
        icon: Icons.casino_rounded,
        accent: RevisionColors.coral,
        completedLessons: 0,
        totalLessons: 6,
        durationMinutes: 15,
        difficulty: 'À lancer',
        mastery: 0,
        sources: [
          MvpSourceFile(
            fileName: 'probabilites.pdf',
            sizeLabel: '2,2 Mo',
            statusLabel: 'À traiter',
          ),
        ],
        learnItems: [
          'Identifier les événements',
          'Calculer une probabilité conditionnelle',
        ],
        keyPoints: ['P(A ∩ B) = P(A)P(B) si indépendants'],
        commonMistakes: ['Confondre union et intersection'],
        weakSpot: 'Probabilité conditionnelle',
      ),
    ],
  ),
  MvpSubject(
    id: 'philo',
    name: 'Philosophie',
    subtitle: 'Continue ton progrès',
    accent: RevisionColors.philosophyAccent,
    icon: Icons.account_balance_rounded,
    courses: [
      MvpCourse(
        id: 'kant',
        subjectId: 'philo',
        title: 'Kant',
        chapterLabel: 'Leçon 2',
        description: 'Devoir, raison pratique et autonomie morale.',
        icon: Icons.menu_book_rounded,
        accent: RevisionColors.pink,
        completedLessons: 2,
        totalLessons: 6,
        durationMinutes: 22,
        difficulty: 'Intermédiaire',
        mastery: 0.36,
        sources: [
          MvpSourceFile(
            fileName: 'kant_devoir.pdf',
            sizeLabel: '1,9 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'notes_kant.pdf',
            sizeLabel: '850 Ko',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Comprendre l’impératif catégorique',
          'Distinguer devoir et intérêt',
        ],
        keyPoints: [
          'La morale suppose l’autonomie',
          'L’action morale vaut par son intention',
        ],
        commonMistakes: ['Réduire Kant à une morale de l’obéissance'],
        weakSpot: 'Impératif catégorique',
      ),
      MvpCourse(
        id: 'descartes',
        subjectId: 'philo',
        title: 'Descartes',
        chapterLabel: 'Leçon 3',
        description: 'Doute méthodique, cogito et vérité.',
        icon: Icons.psychology_rounded,
        accent: RevisionColors.amber,
        completedLessons: 1,
        totalLessons: 6,
        durationMinutes: 20,
        difficulty: 'Facile',
        mastery: 0.20,
        sources: [
          MvpSourceFile(
            fileName: 'descartes_cogito.pdf',
            sizeLabel: '1,4 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Comprendre le doute méthodique', 'Expliquer le cogito'],
        keyPoints: ['Le doute sert à fonder une certitude'],
        commonMistakes: ['Confondre doute sceptique et doute méthodique'],
        weakSpot: 'Cogito',
      ),
      MvpCourse(
        id: 'liberte-devoir',
        subjectId: 'philo',
        title: 'Liberté et devoir',
        chapterLabel: 'Leçon 4',
        description: 'Responsabilité, contrainte et autonomie.',
        icon: Icons.balance_rounded,
        accent: RevisionColors.mint,
        completedLessons: 0,
        totalLessons: 5,
        durationMinutes: 18,
        difficulty: 'À lancer',
        mastery: 0,
        sources: [
          MvpSourceFile(
            fileName: 'liberte_devoir.pdf',
            sizeLabel: '2,1 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Distinguer liberté et caprice',
          'Relier devoir et autonomie',
        ],
        keyPoints: [
          'Une contrainte peut rendre libre si elle structure l’action',
        ],
        commonMistakes: ['Opposer mécaniquement liberté et devoir'],
        weakSpot: 'Définitions',
      ),
    ],
  ),
];
