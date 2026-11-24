enum AppFlavor { dev, staging, prod }

class FlavorConfig {
  final AppFlavor flavor;
  final String name;
  final String apiBaseUrl;
  final String appIdentifier;
  final bool enableLogging;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.apiBaseUrl,
    required this.appIdentifier,
    required this.enableLogging,
  });

  static void init({
    required AppFlavor flavor,
    required String name,
    required String apiBaseUrl,
    required String appIdentifier,
    bool enableLogging = false,
  }) {
    if (flavor == AppFlavor.prod) {
      final uri = Uri.tryParse(apiBaseUrl);
      if (uri == null || uri.scheme != 'https') {
        throw ArgumentError(
          'Production flavor requires secure HTTPS apiBaseUrl, got: $apiBaseUrl',
        );
      }
      final host = uri.host.toLowerCase();
      if (host.isEmpty ||
          host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '10.0.2.2' ||
          host.contains('staging') ||
          host.contains('dev') ||
          host.contains('local') ||
          host.contains('test')) {
        throw ArgumentError(
          'Production flavor cannot point to local, staging, or test endpoint: $apiBaseUrl',
        );
      }
    }

    _instance = FlavorConfig._(
      flavor: flavor,
      name: name,
      apiBaseUrl: apiBaseUrl,
      appIdentifier: appIdentifier,
      enableLogging: enableLogging,
    );
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Call FlavorConfig.init(...) in your main entrypoint.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;
  static bool get isDev => _instance?.flavor == AppFlavor.dev;
  static bool get isStaging => _instance?.flavor == AppFlavor.staging;
  static bool get isProd => _instance?.flavor == AppFlavor.prod;
}
