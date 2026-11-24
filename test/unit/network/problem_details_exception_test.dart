import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/network/problem_details_exception.dart';

void main() {
  group('ProblemDetailsException', () {
    test('parses full RFC 7807 payload with validation errors', () {
      final json = {
        'type': 'https://api.usayd.academy/errors/VALIDATION_FAILED',
        'title': 'Validation Failed',
        'status': 422,
        'detail': 'The provided input fields failed validation.',
        'instance': '/api/v1/auth/register',
        'code': 'VALIDATION_FAILED',
        'traceId': 'trace-uuid-1234',
        'invalidParams': {
          'email': ['The email field is required.'],
          'password': ['Password must be at least 8 characters.'],
        },
      };

      final exception = ProblemDetailsException.fromJson(json);

      expect(exception.status, 422);
      expect(exception.code, 'VALIDATION_FAILED');
      expect(exception.title, 'Validation Failed');
      expect(exception.traceId, 'trace-uuid-1234');
      expect(exception.instance, '/api/v1/auth/register');
      expect(exception.isValidation, isTrue);
      expect(exception.isUnauthorized, isFalse);
      expect(
        exception.invalidParams['email'],
        contains('The email field is required.'),
      );
      expect(
        exception.invalidParams['password'],
        contains('Password must be at least 8 characters.'),
      );
    });

    test('correctly evaluates error classification getters', () {
      const e401 = ProblemDetailsException(
        title: 'T',
        status: 401,
        detail: 'D',
        code: 'UNAUTHORIZED',
      );
      expect(e401.isUnauthorized, isTrue);

      const e403 = ProblemDetailsException(
        title: 'T',
        status: 403,
        detail: 'D',
        code: 'FORBIDDEN',
      );
      expect(e403.isForbidden, isTrue);

      const e404 = ProblemDetailsException(
        title: 'T',
        status: 404,
        detail: 'D',
        code: 'NOT_FOUND',
      );
      expect(e404.isNotFound, isTrue);

      const e409 = ProblemDetailsException(
        title: 'T',
        status: 409,
        detail: 'D',
        code: 'CONFLICT',
      );
      expect(e409.isConflict, isTrue);

      const e429 = ProblemDetailsException(
        title: 'T',
        status: 429,
        detail: 'D',
        code: 'RATE_LIMITED',
      );
      expect(e429.isRateLimited, isTrue);

      const e500 = ProblemDetailsException(
        title: 'T',
        status: 500,
        detail: 'D',
        code: 'INTERNAL_ERROR',
      );
      expect(e500.isServerError, isTrue);
    });

    test('handles fallback when non-standard json is provided', () {
      final exception = ProblemDetailsException.fromJson(
        {},
        fallbackStatus: 503,
      );

      expect(exception.status, 503);
      expect(exception.code, 'UNKNOWN_ERROR');
      expect(exception.title, 'Error');
      expect(exception.invalidParams, isEmpty);
    });
  });
}
