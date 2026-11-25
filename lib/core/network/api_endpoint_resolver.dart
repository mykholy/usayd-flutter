/// Resolves contract paths consistently for host-only and versioned base URLs.
class ApiEndpointResolver {
  const ApiEndpointResolver(this.baseUrl);

  final String baseUrl;
  static const _apiPrefix = '/api/v1';

  Uri resolve(String path) {
    final base = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final pathOnly = path.split(RegExp(r'[?#]')).first;
    final hasVersionedPath =
        pathOnly == _apiPrefix || pathOnly.startsWith('$_apiPrefix/');
    if (base.endsWith(_apiPrefix) && hasVersionedPath) {
      return Uri.parse('$base${path.substring(_apiPrefix.length)}');
    }
    return Uri.parse('$base$path');
  }
}
