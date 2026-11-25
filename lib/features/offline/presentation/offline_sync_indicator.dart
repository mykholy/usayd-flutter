import 'package:flutter/material.dart';
import '../../../core/offline/sync_engine.dart';
import '../../../core/theme/usayd_colors.dart';

class OfflineSyncIndicator extends StatelessWidget {
  final OfflineSyncEngine syncEngine;
  final int pendingCount;
  final int conflictCount;
  final VoidCallback? onSyncPressed;

  const OfflineSyncIndicator({
    super.key,
    required this.syncEngine,
    this.pendingCount = 0,
    this.conflictCount = 0,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0 && conflictCount == 0 && !syncEngine.isSyncing) {
      return const SizedBox.shrink();
    }

    final colors =
        Theme.of(context).extension<UsaydColorScheme>() ??
        UsaydColorScheme.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (conflictCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.errBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.err, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.err, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic
                    ? 'يوجد $conflictCount تعارض في المزامنة يتطلب المراجعة'
                    : '$conflictCount sync conflict(s) require review',
                style: TextStyle(
                  color: colors.err,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (syncEngine.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.okBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.ok, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.ok,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? 'جاري مزامنة التغييرات المحفوظة محلياً...'
                    : 'Syncing offline changes...',
                style: TextStyle(
                  color: colors.ok,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.bgSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_queue_rounded, color: colors.brass, size: 18),
          const SizedBox(width: 8),
          Text(
            isArabic
                ? '$pendingCount في الانتظار'
                : '$pendingCount pending sync',
            style: TextStyle(
              color: colors.tx,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onSyncPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                isArabic ? 'مزامنة الآن' : 'Sync now',
                style: TextStyle(
                  color: colors.brass,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
