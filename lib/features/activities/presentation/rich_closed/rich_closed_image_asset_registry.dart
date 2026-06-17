import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedImageAssetView {
  const RichClosedImageAssetView({
    required this.assetPath,
    required this.fallbackLabel,
    required this.altText,
  });

  final String? assetPath;
  final String fallbackLabel;
  final String altText;
}

RichClosedImageAssetView resolveRichClosedImageAssetView(
  RichClosedImageChoiceOption option,
) {
  // V1-D keeps images allowlisted without remote URLs. The UI fallback stays
  // neutral so the app registry does not reintroduce semantic answer hints.
  return RichClosedImageAssetView(
    assetPath: null,
    fallbackLabel: option.caption ?? option.label,
    altText: option.altText,
  );
}
