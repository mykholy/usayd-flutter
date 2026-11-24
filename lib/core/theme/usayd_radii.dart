import 'package:flutter/material.dart';

/// Corner radius tokens for Usayd Academy
/// Source: `tokens.json` (primitives.radius)
abstract final class UsaydRadii {
  /// 0 px
  static const BorderRadius none = BorderRadius.zero;

  /// 4 px
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4.0));

  /// 6 px
  static const BorderRadius sm = BorderRadius.all(Radius.circular(6.0));

  /// 14 px
  static const BorderRadius md = BorderRadius.all(Radius.circular(14.0));

  /// 20 px
  static const BorderRadius lg = BorderRadius.all(Radius.circular(20.0));

  /// 28 px
  static const BorderRadius xl = BorderRadius.all(Radius.circular(28.0));

  /// 999 px (pills and round badges)
  static const BorderRadius full = BorderRadius.all(Radius.circular(999.0));

  /// Arch radius (top rounded 999 px, flat bottom)
  static const BorderRadius arch = BorderRadius.vertical(
    top: Radius.circular(999.0),
  );
}
