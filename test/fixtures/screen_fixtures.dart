import 'package:flutter/material.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/theme/usayd_colors.dart';
import 'package:usayd_flutter/core/theme/usayd_mode_theme.dart';
import 'package:usayd_flutter/core/theme/usayd_spacing.dart';
import 'package:usayd_flutter/core/theme/usayd_typography.dart';
import 'package:usayd_flutter/core/widgets/screen_state_view.dart';

/// Test fixtures providing standardized canonical screen state representations
/// across Kids, Pro, and Simple modes per `SCREEN_INVENTORY.csv` and `AGE_ADAPTIVE_UI.md`.
class ScreenFixtures {
  /// Fixture 1: Loading state
  static Widget loading({
    InterfaceMode mode = InterfaceMode.pro,
    String? message,
  }) {
    return ScreenStateView.loading(overrideMode: mode, message: message);
  }

  /// Fixture 2: Empty state
  static Widget empty({
    InterfaceMode mode = InterfaceMode.pro,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? customIcon,
  }) {
    return ScreenStateView.empty(
      overrideMode: mode,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      customIcon: customIcon,
    );
  }

  /// Fixture 3: Error state
  static Widget error({
    InterfaceMode mode = InterfaceMode.pro,
    String? title,
    String? message,
    Object? error,
    VoidCallback? onRetry,
  }) {
    return ScreenStateView.error(
      overrideMode: mode,
      title: title,
      message: message,
      error: error,
      onRetry: onRetry,
    );
  }

  /// Fixture 4: Content state with sample adaptive content card
  static Widget content({
    InterfaceMode mode = InterfaceMode.pro,
    Widget? customChild,
  }) {
    return ScreenStateView.content(
      overrideMode: mode,
      child: customChild ?? SampleContentCard(mode: mode),
    );
  }

  /// Fixture 5: Offline banner state
  static Widget offlineBanner({
    InterfaceMode mode = InterfaceMode.pro,
    int pendingActionsCount = 3,
    VoidCallback? onSync,
    Widget? child,
  }) {
    return ScreenStateView.offlineBanner(
      overrideMode: mode,
      pendingActionsCount: pendingActionsCount,
      onSync: onSync,
      child: child ?? SampleContentCard(mode: mode),
    );
  }

  /// Fixture 6: Permission denied state
  static Widget permissionDenied({
    InterfaceMode mode = InterfaceMode.pro,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return ScreenStateView.permissionDenied(
      overrideMode: mode,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Sample adaptive content card used in content and offline fixtures
/// to showcase authentic mode-specific visual rendering.
class SampleContentCard extends StatelessWidget {
  final InterfaceMode mode;

  const SampleContentCard({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final modeTheme =
        theme.extension<UsaydModeTheme>() ?? UsaydModeTheme.forMode(mode);

    switch (mode) {
      case InterfaceMode.kids:
        return _buildKidsCard(colors, modeTheme);
      case InterfaceMode.pro:
        return _buildProCard(colors, modeTheme);
      case InterfaceMode.simple:
        return _buildSimpleCard(colors, modeTheme);
    }
  }

  Widget _buildKidsCard(UsaydColorScheme colors, UsaydModeTheme modeTheme) {
    return Card(
      elevation: 0,
      color: colors.bgRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(modeTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UsaydSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.lamp.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: colors.brass,
                    size: 28,
                  ),
                ),
                const SizedBox(width: UsaydSpacing.smPlus),
                Expanded(
                  child: Text(
                    'مهمة اليوم: سورة الفجر (١-١٤)',
                    style: UsaydTypography.headingM.copyWith(color: colors.tx),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UsaydSpacing.md),
            Text(
              'استمع إلى الشيخ وردد الآيات باطمئنان لتجمع ٥ نجوم مباركة ⭐',
              style: UsaydTypography.bodyM.copyWith(
                fontSize: modeTheme.bodyTextSize,
                color: colors.tx2,
              ),
            ),
            const SizedBox(height: UsaydSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: modeTheme.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('ابدأ المهمة الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.bgBrand,
                  foregroundColor: colors.txOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      modeTheme.cardRadius / 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard(UsaydColorScheme colors, UsaydModeTheme modeTheme) {
    return Card(
      elevation: 0,
      color: colors.bgRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(modeTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'جلسة الحفظ الأسبوعية',
                    style: UsaydTypography.headingM.copyWith(color: colors.tx),
                  ),
                ),
                const SizedBox(width: UsaydSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UsaydSpacing.sm,
                    vertical: UsaydSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.okBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'مكتمل ٨٠٪',
                    style: UsaydTypography.caption.copyWith(color: colors.ok),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UsaydSpacing.sm),
            Text(
              'المقرر: سورة الكهف، الجزء الخامس عشر — مراجعة أحكام النون الساكنة.',
              style: UsaydTypography.bodyM.copyWith(
                fontSize: modeTheme.bodyTextSize,
                color: colors.tx2,
              ),
            ),
            const SizedBox(height: UsaydSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: modeTheme.buttonHeight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.bgBrand,
                  foregroundColor: colors.txOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      modeTheme.cardRadius / 2,
                    ),
                  ),
                ),
                child: const Text('متابعة التسميع'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard(UsaydColorScheme colors, UsaydModeTheme modeTheme) {
    return Card(
      elevation: 0,
      color: colors.bgRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(modeTheme.cardRadius),
        side: BorderSide(
          color: colors.lineStrong,
          width: modeTheme.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'درس اليوم',
              style: UsaydTypography.headingL.copyWith(
                color: colors.tx,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UsaydSpacing.sm),
            Text(
              'مراجعة سورة يس مع المعلم في تمام الساعة الرابعة عصراً بتوقيت القاهرة.',
              style: UsaydTypography.bodyL.copyWith(
                fontSize: modeTheme.bodyTextSize,
                color: colors.tx,
                height: 1.5,
              ),
            ),
            const SizedBox(height: UsaydSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: modeTheme.buttonHeight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.bgBrand,
                  foregroundColor: colors.txOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'دخول حلقة الدرس',
                  style: TextStyle(
                    fontSize: modeTheme.bodyTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
