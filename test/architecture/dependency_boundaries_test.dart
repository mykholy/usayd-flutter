import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _packagePrefix = 'package:usayd_flutter/';
const _legacyShellTab = 'lib/features/shell/domain/shell_tab.dart';

void main() {
  test('production imports respect feature architecture boundaries', () {
    final violations = <String>[];
    final directives = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in sources) {
      final path = file.path.replaceAll('\\', '/');
      for (final match in directives.allMatches(file.readAsStringSync())) {
        final dependency = match.group(1)!;
        final target = _localPath(file, dependency);
        if (target != null &&
            (target.startsWith('test/') || target.contains('/mock/'))) {
          violations.add('$path imports fixture $dependency');
        }

        if (!path.startsWith('lib/features/')) continue;
        final parts = path.split('/');
        if (parts.length < 5) continue;
        final feature = 'lib/features/' + parts[2] + '/';
        final layer = parts[3];

        // Existing IconData-based navigation metadata; migrate separately.
        if (path == _legacyShellTab) continue;

        if (layer == 'domain' || layer == 'application') {
          if (target == null) {
            if (!dependency.startsWith('dart:') ||
                const [
                  'dart:io',
                  'dart:ui',
                  'dart:ffi',
                  'dart:html',
                ].contains(dependency)) {
              violations.add('$path imports platform code $dependency');
            }
          } else {
            final allowed =
                target.startsWith(feature + 'domain/') ||
                target.startsWith('lib/core/result/') ||
                (layer == 'application' &&
                    target.startsWith(feature + 'application/'));
            if (!allowed) {
              violations.add('$path imports outer layer $dependency');
            }
          }
        }

        if (layer == 'presentation' &&
            (dependency.startsWith('package:http/') ||
                dependency.startsWith('package:flutter_secure_storage/') ||
                (target != null &&
                    (target.startsWith('lib/core/network/') ||
                        target.contains('/data/'))))) {
          violations.add('$path bypasses application boundary: $dependency');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

String? _localPath(File source, String dependency) {
  if (dependency.startsWith(_packagePrefix)) {
    return 'lib/' + dependency.substring(_packagePrefix.length);
  }
  if (dependency.contains(':')) return null;
  final root = Directory.current.absolute.path.replaceAll('\\', '/');
  final target = source.absolute.uri
      .resolve(dependency)
      .toFilePath()
      .replaceAll('\\', '/');
  return target.startsWith('$root/')
      ? target.substring(root.length + 1)
      : target;
}
