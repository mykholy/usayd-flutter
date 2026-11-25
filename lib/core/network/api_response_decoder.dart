import 'dart:convert';

import 'package:http/http.dart' as http;

import 'problem_details_exception.dart';

/// A successful HTTP response whose body violates the JSON contract.
class MalformedSuccessResponse extends FormatException {
  const MalformedSuccessResponse()
    : super('Expected a JSON object in API response.');
}

/// Decodes the API envelope independently of transport and session state.
class ApiResponseDecoder {
  const ApiResponseDecoder();

  Map<String, dynamic> decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      } on FormatException {
        throw const MalformedSuccessResponse();
      }
      throw const MalformedSuccessResponse();
    }

    // Parse RFC 7807 problem details or fallback
    Map<String, dynamic> errorJson = {};
    try {
      errorJson = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      errorJson = {
        'title': 'HTTP ${response.statusCode}',
        'detail': response.body.isNotEmpty ? response.body : 'Request failed.',
        'status': response.statusCode,
        'code': 'HTTP_${response.statusCode}',
      };
    }

    throw ProblemDetailsException.fromJson(
      errorJson,
      fallbackStatus: response.statusCode,
    );
  }
}
