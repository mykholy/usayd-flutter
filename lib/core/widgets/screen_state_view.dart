import 'package:flutter/material.dart';
import '../config/interface_mode.dart';
import '../network/problem_details_exception.dart';
import '../theme/usayd_colors.dart';
import '../theme/usayd_mode_theme.dart';
import '../theme/usayd_spacing.dart';
import '../theme/usayd_typography.dart';

/// The 6 canonical screen states defined in the Usayd Academy design system
/// and SCREEN_INVENTORY.csv.
enum ScreenState {
  loading,
  empty,
  error,
  content,
  offlineBanner,
  permissionDenied,
}

/// Unified widget rendering the 6 canonical screen states with full
/// age-adaptive support across Kids, Pro, and Simple modes per `AGE_ADAPTIVE_UI.md`.
class ScreenStateView extends StatelessWidget {
  final ScreenState state;
  final Widget? child;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;
  final Object? error;
  final int pendingActionsCount;
  final VoidCallback? onSync;
  final InterfaceMode? overrideMode;
  final IconData? customIcon;

  const ScreenStateView({
    super.key,
    required this.state,
    this.child,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onRetry,
    this.error,
    this.pendingActionsCount = 0,
    this.onSync,
    this.overrideMode,
    this.customIcon,
  });

  /// Factory constructors for convenient fixture & screen creation
  const ScreenStateView.loading({
    super.key,
    this.title,
    this.message,
    this.overrideMode,
  }) : state = ScreenState.loading,
       child = null,
       actionLabel = null,
       onAction = null,
       onRetry = null,
       error = null,
       pendingActionsCount = 0,
       onSync = null,
       customIcon = null;

  const ScreenStateView.empty({
    super.key,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.overrideMode,
    this.customIcon,
  }) : state = ScreenState.empty,
       child = null,
       onRetry = null,
       error = null,
       pendingActionsCount = 0,
       onSync = null;

  const ScreenStateView.error({
    super.key,
    this.title,
    this.message,
    this.error,
    this.onRetry,
    this.overrideMode,
    this.customIcon,
  }) : state = ScreenState.error,
       child = null,
       actionLabel = null,
       onAction = null,
       pendingActionsCount = 0,
       onSync = null;

  const ScreenStateView.content({
    super.key,
    required Widget this.child,
    this.overrideMode,
  }) : state = ScreenState.content,
       title = null,
       message = null,
       actionLabel = null,
       onAction = null,
       onRetry = null,
       error = null,
       pendingActionsCount = 0,
       onSync = null,
       customIcon = null;

  const ScreenStateView.offlineBanner({
    super.key,
    this.child,
    this.title,
    this.message,
    this.pendingActionsCount = 0,
    this.onSync,
    this.overrideMode,
  }) : state = ScreenState.offlineBanner,
       actionLabel = null,
       onAction = null,
       onRetry = null,
       error = null,
       customIcon = null;

  const ScreenStateView.permissionDenied({
    super.key,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.overrideMode,
    this.customIcon,
  }) : state = ScreenState.permissionDenied,
       child = null,
       onRetry = null,
       error = null,
       pendingActionsCount = 0,
       onSync = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final modeTheme = overrideMode != null
        ? UsaydModeTheme.forMode(overrideMode!)
        : (theme.extension<UsaydModeTheme>() ?? UsaydModeTheme.pro());
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    switch (state) {
      case ScreenState.content:
        return child ?? const SizedBox.shrink();

      case ScreenState.loading:
        return _buildLoading(context, colors, modeTheme, isArabic);

      case ScreenState.empty:
        return _buildEmpty(context, colors, modeTheme, isArabic);

      case ScreenState.error:
        return _buildError(context, colors, modeTheme, isArabic);

      case ScreenState.offlineBanner:
        return _buildOfflineBanner(context, colors, modeTheme, isArabic);

      case ScreenState.permissionDenied:
        return _buildPermissionDenied(context, colors, modeTheme, isArabic);
    }
  }

  Widget _buildLoading(
    BuildContext context,
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    bool isArabic,
  ) {
    final defaultMsg = isArabic
        ? (modeTheme.mode == InterfaceMode.kids
              ? 'جارٍ تجهيز مهامك الجميلة...'
              : (modeTheme.mode == InterfaceMode.simple
                    ? 'جارٍ التحميل... يرجى الانتظار'
                    : 'جارٍ تحميل البيانات...'))
        : (modeTheme.mode == InterfaceMode.kids
              ? 'Loading your awesome missions...'
              : 'Loading data...');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(UsaydSpacing.xl),
          decoration: BoxDecoration(
            color: colors.bgRaised,
            borderRadius: BorderRadius.circular(modeTheme.cardRadius),
            border: modeTheme.cardBorderWidth > 0
                ? Border.all(
                    color: colors.lineStrong,
                    width: modeTheme.cardBorderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: modeTheme.mode == InterfaceMode.simple ? 48 : 36,
                height: modeTheme.mode == InterfaceMode.simple ? 48 : 36,
                child: CircularProgressIndicator(
                  strokeWidth: modeTheme.mode == InterfaceMode.simple
                      ? 4.0
                      : 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    modeTheme.mode == InterfaceMode.kids
                        ? colors.lamp
                        : colors.act,
                  ),
                ),
              ),
              const SizedBox(height: UsaydSpacing.lg),
              Text(
                message ?? defaultMsg,
                textAlign: TextAlign.center,
                style: UsaydTypography.bodyM.copyWith(
                  fontSize: modeTheme.bodyTextSize,
                  fontWeight: modeTheme.mode == InterfaceMode.simple
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: colors.tx,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    bool isArabic,
  ) {
    final defaultTitle = isArabic
        ? (modeTheme.mode == InterfaceMode.kids
              ? 'لا توجد مهام جديدة اليوم!'
              : (modeTheme.mode == InterfaceMode.simple
                    ? 'لا توجد دروس مسجلة'
                    : 'لا توجد عناصر لعرضها'))
        : 'No items available';

    final defaultMessage = isArabic
        ? (modeTheme.mode == InterfaceMode.kids
              ? 'أحسنت! أكملت كل المهام المقررة. واصل إشراقك ✨'
              : 'يمكنك البدء بحفظ جديد أو تصفح الدروس المتاحة.')
        : 'You can start a new memorization or browse available lessons.';

    final icon =
        customIcon ??
        (modeTheme.mode == InterfaceMode.kids
            ? Icons.star_rounded
            : Icons.inbox_outlined);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(UsaydSpacing.xl),
          decoration: BoxDecoration(
            color: colors.bgRaised,
            borderRadius: BorderRadius.circular(modeTheme.cardRadius),
            border: modeTheme.cardBorderWidth > 0
                ? Border.all(
                    color: colors.lineStrong,
                    width: modeTheme.cardBorderWidth,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: modeTheme.mode == InterfaceMode.simple ? 64 : 52,
                color: modeTheme.mode == InterfaceMode.kids
                    ? colors.lamp
                    : colors.tx3,
              ),
              const SizedBox(height: UsaydSpacing.md),
              Text(
                title ?? defaultTitle,
                textAlign: TextAlign.center,
                style: UsaydTypography.headingM.copyWith(
                  color: colors.tx,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UsaydSpacing.sm),
              Text(
                message ?? defaultMessage,
                textAlign: TextAlign.center,
                style: UsaydTypography.bodyM.copyWith(
                  fontSize: modeTheme.bodyTextSize,
                  color: colors.tx2,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: UsaydSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: modeTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.bgBrand,
                      foregroundColor: colors.txOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          modeTheme.cardRadius / 2,
                        ),
                      ),
                    ),
                    child: Text(
                      actionLabel ?? (isArabic ? 'ابدأ الآن' : 'Get Started'),
                      style: UsaydTypography.bodyL.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.txOnBrand,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    bool isArabic,
  ) {
    String errorDetail = '';
    if (error is ProblemDetailsException) {
      final pde = error as ProblemDetailsException;
      errorDetail = pde.detail.isNotEmpty ? pde.detail : pde.title;
    } else if (error != null) {
      errorDetail = error.toString();
    }

    final defaultTitle = isArabic
        ? 'تعذر تحميل البيانات'
        : 'Unable to load data';
    final defaultMessage =
        message ??
        (errorDetail.isNotEmpty
            ? errorDetail
            : (isArabic
                  ? 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً.'
                  : 'Please check your connection and try again.'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(UsaydSpacing.xl),
          decoration: BoxDecoration(
            color: colors.errBg,
            borderRadius: BorderRadius.circular(modeTheme.cardRadius),
            border: Border.all(
              color: colors.err.withAlpha(120),
              width: modeTheme.cardBorderWidth > 0
                  ? modeTheme.cardBorderWidth
                  : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                customIcon ?? Icons.error_outline_rounded,
                size: modeTheme.mode == InterfaceMode.simple ? 56 : 48,
                color: colors.err,
              ),
              const SizedBox(height: UsaydSpacing.md),
              Text(
                title ?? defaultTitle,
                textAlign: TextAlign.center,
                style: UsaydTypography.headingM.copyWith(
                  color: colors.err,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UsaydSpacing.sm),
              Text(
                defaultMessage,
                textAlign: TextAlign.center,
                style: UsaydTypography.bodyM.copyWith(
                  fontSize: modeTheme.bodyTextSize,
                  color: colors.tx,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: UsaydSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: modeTheme.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      isArabic ? 'إعادة المحاولة' : 'Try Again',
                      style: UsaydTypography.bodyL.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.txOnBrand,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.err,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(
    BuildContext context,
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    bool isArabic,
  ) {
    final bannerWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UsaydSpacing.md,
        vertical: UsaydSpacing.smPlus,
      ),
      decoration: BoxDecoration(
        color: colors.warnBg,
        border: Border(bottom: BorderSide(color: colors.warn, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.warn, size: 22),
          const SizedBox(width: UsaydSpacing.sm),
          Expanded(
            child: Text(
              pendingActionsCount > 0
                  ? (isArabic
                        ? 'وضع غير متصل — $pendingActionsCount عملية بانتظار المزامنة'
                        : 'Offline mode — $pendingActionsCount actions queued')
                  : (isArabic
                        ? 'أنت تعمل في وضع عدم الاتصال — البيانات محفوظة محلياً'
                        : 'You are working offline — data saved locally'),
              style: TextStyle(
                fontSize: modeTheme.mode == InterfaceMode.simple ? 16 : 13,
                fontWeight: FontWeight.bold,
                color: colors.warn,
              ),
            ),
          ),
          if (onSync != null) ...[
            const SizedBox(width: UsaydSpacing.xs),
            IconButton(
              onPressed: onSync,
              icon: const Icon(Icons.sync_rounded),
              color: colors.warn,
              tooltip: isArabic ? 'مزامنة الآن' : 'Sync now',
            ),
          ],
        ],
      ),
    );

    if (child != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [bannerWidget, child!],
      );
    }

    return bannerWidget;
  }

  Widget _buildPermissionDenied(
    BuildContext context,
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    bool isArabic,
  ) {
    final defaultTitle = isArabic ? 'الإذن مطلوب' : 'Permission Required';
    final defaultMsg = isArabic
        ? 'يتطلب هذا الإجراء صلاحية خاصة للوصول (مثل الميكروفون أو موافقة ولي الأمر).'
        : 'This action requires special permission (such as microphone or guardian consent).';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UsaydSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(UsaydSpacing.xl),
          decoration: BoxDecoration(
            color: colors.bgRaised,
            borderRadius: BorderRadius.circular(modeTheme.cardRadius),
            border: modeTheme.cardBorderWidth > 0
                ? Border.all(
                    color: colors.lineStrong,
                    width: modeTheme.cardBorderWidth,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                customIcon ?? Icons.lock_outline_rounded,
                size: modeTheme.mode == InterfaceMode.simple ? 60 : 48,
                color: colors.warn,
              ),
              const SizedBox(height: UsaydSpacing.md),
              Text(
                title ?? defaultTitle,
                textAlign: TextAlign.center,
                style: UsaydTypography.headingM.copyWith(
                  color: colors.tx,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UsaydSpacing.sm),
              Text(
                message ?? defaultMsg,
                textAlign: TextAlign.center,
                style: UsaydTypography.bodyM.copyWith(
                  fontSize: modeTheme.bodyTextSize,
                  color: colors.tx2,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: UsaydSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: modeTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.bgBrand,
                      foregroundColor: colors.txOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          modeTheme.cardRadius / 2,
                        ),
                      ),
                    ),
                    child: Text(
                      actionLabel ??
                          (isArabic ? 'منح الإذن' : 'Grant Permission'),
                      style: UsaydTypography.bodyL.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.txOnBrand,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
