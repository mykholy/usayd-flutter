import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/constants/asset_paths.dart';

void main() {
  group('UsaydAssets Canonical Asset Tests', () {
    test('All brand mark and icon asset files exist on disk', () {
      final iconPaths = [
        UsaydAssets.appIcon,
        UsaydAssets.markColor,
        UsaydAssets.markReverse,
      ];

      for (final path in iconPaths) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Asset missing: $path');
        expect(file.lengthSync(), greaterThan(0), reason: 'Empty asset: $path');
      }
    });

    test('Kids mode illustrations and badges exist on disk', () {
      final kidsAssets = [
        UsaydAssets.kidsScene,
        UsaydAssets.kidsFinish,
        UsaydAssets.kidsBadgeBookOpen,
        UsaydAssets.kidsBadgeBookOpenLocked,
        UsaydAssets.kidsBadgeCrown,
        UsaydAssets.kidsBadgeCrownLocked,
        UsaydAssets.kidsLanternCoral,
        UsaydAssets.kidsLanternGold,
        UsaydAssets.kidsLanternMint,
        UsaydAssets.kidsLanternSky,
      ];

      for (final path in kidsAssets) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Kids asset missing: $path');
        expect(file.lengthSync(), greaterThan(0));
      }
    });

    test('Spot status illustrations exist on disk', () {
      final spotAssets = [
        UsaydAssets.spotAi,
        UsaydAssets.spotCompetition,
        UsaydAssets.spotDenied,
        UsaydAssets.spotEmpty,
        UsaydAssets.spotError,
        UsaydAssets.spotFoundations,
        UsaydAssets.spotLive,
        UsaydAssets.spotMemorize,
        UsaydAssets.spotOffline,
        UsaydAssets.spotReview,
        UsaydAssets.spotSuccess,
        UsaydAssets.spotTajweed,
        UsaydAssets.spotTeacher,
      ];

      for (final path in spotAssets) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Spot asset missing: $path');
        expect(file.lengthSync(), greaterThan(0));
      }
    });

    test('Asset paths adhere to naming convention and .svg extension', () {
      final allAssets = [
        UsaydAssets.appIcon,
        UsaydAssets.markColor,
        UsaydAssets.markReverse,
        UsaydAssets.heroNightScene,
        UsaydAssets.kidsScene,
        UsaydAssets.spotSuccess,
        UsaydAssets.spotTajweed,
      ];

      for (final path in allAssets) {
        expect(path.startsWith('assets/'), isTrue);
        expect(path.endsWith('.svg'), isTrue);
      }
    });
  });
}
