import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/config/flavor_config.dart';
import '../../../../core/config/interface_mode.dart';
import '../../../../core/config/user_preferences.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/usayd_localizations.dart';
import '../../../../core/theme/usayd_colors.dart';
import '../../../../core/theme/usayd_mode_theme.dart';
import '../../../../core/theme/usayd_spacing.dart';
import '../../../../core/theme/usayd_typography.dart';

class HomeScreen extends StatelessWidget {
  final UserPreferences preferences;
  final ValueChanged<AppLocale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<InterfaceMode> onModeChanged;

  const HomeScreen({
    super.key,
    required this.preferences,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final modeTheme =
        theme.extension<UsaydModeTheme>() ??
        UsaydModeTheme.forMode(preferences.interfaceMode);
    final l10n = UsaydLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.brandName,
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
              const SizedBox(height: UsaydSpacing.sm),
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
                      semanticsLabel: l10n.brandName,
                    ),
                    const SizedBox(height: UsaydSpacing.smPlus),
                    Text(
                      l10n.brandName,
                      style: UsaydTypography.headingL.copyWith(
                        color: colors.txOnBrand,
                      ),
                    ),
                    const SizedBox(height: UsaydSpacing.xs),
                    Text(
                      l10n.tagline,
                      textAlign: TextAlign.center,
                      style: UsaydTypography.bodyM.copyWith(
                        color: colors.lamp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UsaydSpacing.md),
              // Language and Theme Selector Card
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
                      // Language Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.language,
                            style: UsaydTypography.headingS.copyWith(
                              color: colors.tx,
                            ),
                          ),
                          SegmentedButton<AppLocale>(
                            segments: [
                              ButtonSegment<AppLocale>(
                                value: AppLocale.ar,
                                label: Text(l10n.arabic),
                              ),
                              ButtonSegment<AppLocale>(
                                value: AppLocale.en,
                                label: Text(l10n.english),
                              ),
                            ],
                            selected: {preferences.locale},
                            onSelectionChanged: (selection) {
                              onLocaleChanged(selection.first);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: UsaydSpacing.md),
                      // Theme Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.themeMode,
                            style: UsaydTypography.headingS.copyWith(
                              color: colors.tx,
                            ),
                          ),
                          SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                icon: const Icon(
                                  Icons.wb_sunny_rounded,
                                  size: 18,
                                ),
                                label: Text(l10n.themeLight),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                icon: const Icon(
                                  Icons.nightlight_round,
                                  size: 18,
                                ),
                                label: Text(l10n.themeDark),
                              ),
                            ],
                            selected: {
                              preferences.themeMode == ThemeMode.dark
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                            },
                            onSelectionChanged: (selection) {
                              onThemeModeChanged(selection.first);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.md),
              // Adaptive Mode Switcher Card
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
                        l10n.adaptiveModeTitle,
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
                        selected: {preferences.interfaceMode},
                        onSelectionChanged: (selection) {
                          onModeChanged(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.md),
              // Active Mode Details
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
                    children: [
                      _buildModeIllustration(preferences.interfaceMode),
                      const SizedBox(height: UsaydSpacing.smPlus),
                      Text(
                        '${l10n.activeMode} ${preferences.interfaceMode.displayNameArabic} (${preferences.interfaceMode.displayNameEnglish})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: modeTheme.bodyTextSize,
                          fontWeight: FontWeight.bold,
                          color: colors.txBrand,
                        ),
                      ),
                      const SizedBox(height: UsaydSpacing.xs),
                      Text(
                        '${l10n.targetAudience} ${preferences.interfaceMode.recommendedAgeLabel}',
                        textAlign: TextAlign.center,
                        style: UsaydTypography.bodyS.copyWith(
                          color: colors.tx2,
                        ),
                      ),
                      const SizedBox(height: UsaydSpacing.sm),
                      Text(
                        '${l10n.buttonHeight} ${modeTheme.buttonHeight.toInt()}px · ${l10n.cardRadius} ${modeTheme.cardRadius.toInt()}px',
                        textAlign: TextAlign.center,
                        style: UsaydTypography.caption.copyWith(
                          color: colors.tx3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.md),
              // Preference Independence Verification Card (02_locale_independence.mmd)
              Card(
                color: colors.bgRaised,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(modeTheme.cardRadius),
                  side: BorderSide(color: colors.line),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UsaydSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: colors.brass,
                          ),
                          const SizedBox(width: UsaydSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.localeIndependenceNote,
                              style: UsaydTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.tx,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPrefBadge(
                            l10n.market,
                            preferences.marketCountry,
                            colors,
                          ),
                          _buildPrefBadge(
                            l10n.currency,
                            preferences.currency,
                            colors,
                          ),
                          _buildPrefBadge(
                            l10n.timezone,
                            preferences.timezone,
                            colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.sm),
              // Sacred Quran Invariant Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UsaydSpacing.sm,
                ),
                child: Text(
                  l10n.quranPolicy,
                  textAlign: TextAlign.center,
                  style: UsaydTypography.caption.copyWith(
                    color: colors.tx3,
                    fontStyle: FontStyle.italic,
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

  Widget _buildPrefBadge(String title, String value, UsaydColorScheme colors) {
    return Column(
      children: [
        Text(title, style: UsaydTypography.caption.copyWith(color: colors.tx2)),
        const SizedBox(height: UsaydSpacing.xxs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.bgSubtle,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: UsaydTypography.bodyS.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.txBrand,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeIllustration(InterfaceMode mode) {
    final String assetPath = switch (mode) {
      InterfaceMode.kids => UsaydAssets.kidsBadgeCrown,
      InterfaceMode.pro => UsaydAssets.spotTajweed,
      InterfaceMode.simple => UsaydAssets.spotFoundations,
    };

    return SvgPicture.asset(assetPath, width: 64, height: 64);
  }
}
