class ProblemDetailsException implements Exception {
  final String? type;
  final String title;
  final int status;
  final String detail;
  final String? instance;
  final String code;
  final String? traceId;
  final Map<String, List<String>> invalidParams;
  final Map<String, dynamic> extensions;

  const ProblemDetailsException({
    this.type,
    required this.title,
    required this.status,
    required this.detail,
    this.instance,
    required this.code,
    this.traceId,
    this.invalidParams = const {},
    this.extensions = const {},
  });

  factory ProblemDetailsException.fromJson(
    Map<String, dynamic> json, {
    int fallbackStatus = 500,
  }) {
    final rawParams = json['invalidParams'] ?? json['errors'];
    final invalidParams = <String, List<String>>{};

    if (rawParams is Map) {
      rawParams.forEach((key, value) {
        if (value is List) {
          invalidParams[key.toString()] = value
              .map((e) => e.toString())
              .toList();
        } else if (value != null) {
          invalidParams[key.toString()] = [value.toString()];
        }
      });
    }

    return ProblemDetailsException(
      type: json['type'] as String?,
      title: (json['title'] as String?) ?? 'Error',
      status: (json['status'] as int?) ?? fallbackStatus,
      detail: (json['detail'] as String?) ?? 'An unexpected error occurred.',
      instance: json['instance'] as String?,
      code: (json['code'] as String?) ?? 'UNKNOWN_ERROR',
      traceId: json['traceId'] as String?,
      invalidParams: invalidParams,
    );
  }

  bool get isUnauthorized => status == 401;
  bool get isForbidden => status == 403;
  bool get isNotFound => status == 404;
  bool get isConflict => status == 409;
  bool get isValidation => status == 422;
  bool get isRateLimited => status == 429;
  bool get isServerError => status >= 500;

  @override
  String toString() =>
      'ProblemDetailsException(status: $status, code: $code, title: $title, detail: $detail, traceId: $traceId)';
}
