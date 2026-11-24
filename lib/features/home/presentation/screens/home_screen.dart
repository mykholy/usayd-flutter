import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/config/flavor_config.dart';
import '../../../../core/config/interface_mode.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/usayd_colors.dart';
import '../../../../core/theme/usayd_mode_theme.dart';
import '../../../../core/theme/usayd_spacing.dart';
import '../../../../core/theme/usayd_typography.dart';

class HomeScreen extends StatelessWidget {
  final InterfaceMode currentMode;
  final ValueChanged<InterfaceMode> onModeChanged;

  const HomeScreen({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final modeTheme =
        theme.extension<UsaydModeTheme>() ??
        UsaydModeTheme.forMode(currentMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أكاديمية أُسَيْد',
          style: UsaydTypography.headingM.copyWith(color: colors.txOnBrand),
        ),
        centerTitle: true,
        actions: [
          if (!FlavorConfig.isProd)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UsaydSpacing.smPlus,
              ),
              child: Chip(
                label: Text(
                  FlavorConfig.isDev ? 'DEV' : 'STG',
                  style: UsaydTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: FlavorConfig.isDev ? colors.lamp : colors.info,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UsaydSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: UsaydSpacing.md),
              // Brand mark canopy container
              Container(
                padding: const EdgeInsets.all(UsaydSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.bgBrand,
                  borderRadius: BorderRadius.circular(modeTheme.cardRadius),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      UsaydAssets.markReverse,
                      width: 52,
                      height: 52,
                      semanticsLabel: 'شعار أكاديمية أُسَيْد',
                    ),
                    const SizedBox(height: UsaydSpacing.smPlus),
                    Text(
                      'أكاديمية أُسَيْد',
                      style: UsaydTypography.headingL.copyWith(
                        color: colors.txOnBrand,
                      ),
                    ),
                    const SizedBox(height: UsaydSpacing.xs),
                    Text(
                      '«اقرأ بصوتٍ تدنو له الملائكة»',
                      textAlign: TextAlign.center,
                      style: UsaydTypography.bodyM.copyWith(
                        color: colors.lamp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UsaydSpacing.lg),
              // Mode switcher card
              Card(
                elevation: 0,
                color: colors.bgSubtle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(modeTheme.cardRadius),
                  side: modeTheme.cardBorderWidth > 0
                      ? BorderSide(
                          color: colors.lineStrong,
                          width: modeTheme.cardBorderWidth,
                        )
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UsaydSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نمط الواجهة التكيفي:',
                        style: UsaydTypography.headingS.copyWith(
                          color: colors.tx,
                        ),
                      ),
                      const SizedBox(height: UsaydSpacing.smPlus),
                      SegmentedButton<InterfaceMode>(
                        segments: [
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.kids,
                            label: Text(InterfaceMode.kids.displayNameArabic),
                            icon: const Icon(Icons.star_rounded),
                          ),
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.pro,
                            label: Text(InterfaceMode.pro.displayNameArabic),
                            icon: const Icon(Icons.workspace_premium_rounded),
                          ),
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.simple,
                            label: Text(InterfaceMode.simple.displayNameArabic),
                            icon: const Icon(Icons.accessibility_new_rounded),
                          ),
                        ],
                        selected: {currentMode},
                        onSelectionChanged: (selection) {
                          onModeChanged(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.mdPlus),
              // Active mode details & illustration spot
              Card(
                color: colors.bgRaised,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(modeTheme.cardRadius),
                  side: BorderSide(
                    color: modeTheme.cardBorderWidth > 0
                        ? colors.lineStrong
                        : colors.line,
                    width: modeTheme.cardBorderWidth > 0
                        ? modeTheme.cardBorderWidth
                        : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UsaydSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeIllustration(currentMode),
                      const SizedBox(height: UsaydSpacing.md),
                      Text(
                        'النمط النشط: ${currentMode.displayNameArabic} (${currentMode.displayNameEnglish})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: modeTheme.bodyTextSize,
                          fontWeight: FontWeight.bold,
                          color: colors.txBrand,
                        ),
                      ),
                      const SizedBox(height: UsaydSpacing.xs),
                      Text(
                        'الفئة المستهدفة: ${currentMode.recommendedAgeLabel}',
                        textAlign: TextAlign.center,
                        style: UsaydTypography.bodyS.copyWith(
                          color: colors.tx2,
                        ),
                      ),
                      const SizedBox(height: UsaydSpacing.sm),
                      Text(
                        'ارتفاع الأزرار: ${modeTheme.buttonHeight.toInt()}px · زاوية البطاقة: ${modeTheme.cardRadius.toInt()}px',
                        textAlign: TextAlign.center,
                        style: UsaydTypography.caption.copyWith(
                          color: colors.tx3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeIllustration(InterfaceMode mode) {
    final String assetPath = switch (mode) {
      InterfaceMode.kids => UsaydAssets.kidsBadgeCrown,
      InterfaceMode.pro => UsaydAssets.spotTajweed,
      InterfaceMode.simple => UsaydAssets.spotFoundations,
    };

    return SvgPicture.asset(assetPath, width: 72, height: 72);
  }
}
