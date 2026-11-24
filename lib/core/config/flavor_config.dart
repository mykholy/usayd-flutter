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
