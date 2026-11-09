import 'package:flutter/material.dart';

/// Semantic colours that Material's [ColorScheme] doesn't cover.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  static const light = Palette(
    success: Color(0xFF1B7A44),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFCBF0D6),
    onSuccessContainer: Color(0xFF00210F),
  );

  static const dark = Palette(
    success: Color(0xFF86D9A2),
    onSuccess: Color(0xFF00391C),
    successContainer: Color(0xFF0F5230),
    onSuccessContainer: Color(0xFFCBF0D6),
  );

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>()!;

  @override
  Palette copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return Palette(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
    );
  }
}
