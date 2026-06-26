import 'package:flutter/material.dart';

import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../presentation/design_system/tokens/revision_shadows.dart';

class CourseHeroTags {
  const CourseHeroTags._();

  static String card(String courseId) => 'course-$courseId-card';

  static String subjectOverview(String subjectId) =>
      'subject-$subjectId-course-overview-card';

  static String learningPath(String courseId) =>
      'course-$courseId-learning-path-card';

  static String navigationControl() => 'courses-navigation-control';
}

Widget buildCourseCardHeroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  return const _CourseCardHeroFlightSurface();
}

Widget buildCourseNavigationControlHeroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final isPush = flightDirection == HeroFlightDirection.push;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeInOutCubic.transform(
        animation.value.clamp(0.0, 1.0).toDouble(),
      );
      final startOpacity = 1 - _interval(t, 0.0, 0.55);
      final endOpacity = _interval(t, 0.45, 1.0);
      final startIcon = isPush ? Icons.add_rounded : Icons.arrow_back_rounded;
      final endIcon = isPush ? Icons.arrow_back_rounded : Icons.add_rounded;

      return Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RevisionColors.glassStrong,
            borderRadius: RevisionRadius.pill,
            border: Border.all(color: RevisionColors.borderBright),
            boxShadow: RevisionShadows.nav,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: startOpacity,
                child: Transform.rotate(
                  angle: (isPush ? -0.22 : 0.22) * t,
                  child: Icon(startIcon, color: RevisionColors.text),
                ),
              ),
              Opacity(
                opacity: endOpacity,
                child: Transform.rotate(
                  angle: (isPush ? 0.22 : -0.22) * (1 - t),
                  child: Icon(endIcon, color: RevisionColors.text),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

double _interval(double value, double begin, double end) {
  return ((value - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
}

class _CourseCardHeroFlightSurface extends StatelessWidget {
  const _CourseCardHeroFlightSurface();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RevisionColors.glassSoft,
          borderRadius: RevisionRadius.radiusXl,
          border: Border.all(color: RevisionColors.border),
          boxShadow: RevisionShadows.glass,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
