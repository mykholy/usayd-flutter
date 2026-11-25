import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:usayd_flutter/core/network/api_response_decoder.dart';
import 'package:usayd_flutter/core/network/problem_details_exception.dart';

void main() {
  const decoder = ApiResponseDecoder();

  group('ApiResponseDecoder', () {
    test('decodes a JSON object', () {
      expect(decoder.decode(http.Response('{"data":{"id":1}}', 200)), {
        'data': {'id': 1},
      });
    });

    test('accepts an empty no-content response', () {
      expect(decoder.decode(http.Response('', 204)), isEmpty);
    });

    test('does not silently accept malformed successful responses', () {
      for (final body in ['not JSON', '[]', 'null', '42']) {
        expect(
          () => decoder.decode(http.Response(body, 200)),
          throwsFormatException,
        );
      }
    });

    test('preserves typed problem details', () {
      expect(
        () => decoder.decode(
          http.Response('{"status":422,"code":"VALIDATION_ERROR"}', 422),
        ),
        throwsA(
          isA<ProblemDetailsException>()
              .having((error) => error.status, 'status', 422)
              .having((error) => error.code, 'code', 'VALIDATION_ERROR'),
        ),
      );
    });
  });
}
