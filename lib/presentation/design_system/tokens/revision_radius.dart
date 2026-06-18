import 'package:flutter/material.dart';

class RevisionRadius {
  const RevisionRadius._();

  static const double s = 10;
  static const double m = 14;
  static const double l = 18;
  static const double xl = 24;
  static const double xxl = 30;
  static const double pillValue = 999;

  static const radiusS = BorderRadius.all(Radius.circular(s));
  static const radiusM = BorderRadius.all(Radius.circular(m));
  static const radiusL = BorderRadius.all(Radius.circular(l));
  static const radiusXl = BorderRadius.all(Radius.circular(xl));
  static const radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const pill = BorderRadius.all(Radius.circular(pillValue));
}
