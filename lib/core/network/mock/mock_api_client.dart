import '../models/auth_tokens.dart';
import '../models/user_profile.dart';
import '../problem_details_exception.dart';
import '../api_client.dart';

// ============================================================================
// FLAG: TEST FIXTURE ONLY - NEVER USE IN PRODUCTION ENVIRONMENT
// ============================================================================

class MockApiClient extends ApiClient {
  bool shouldFail = false;
  int failureStatusCode = 401;
  String failureCode = 'UNAUTHORIZED';

  AuthTokens mockTokens = const AuthTokens(
    accessToken: 'mock-access-token-xyz-123',
    expiresIn: 3600,
    refreshToken: 'mock-refresh-token-xyz-789',
    tokenType: 'Bearer',
  );

  UserProfile mockProfile = const UserProfile(
    id: 1,
    name: 'أُسَيْد التجريبي',
    email: 'mock.student@usayd.academy',
    phone: '+201000000000',
    locale: 'ar',
    country: 'EG',
    timezone: 'Africa/Cairo',
    status: 'active',
  );

  MockApiClient({
    required super.tokenStorage,
    super.localeProvider,
    super.onUnauthenticated,
  }) : super(baseUrl: 'http://localhost.mock');

  @override
  Future<AuthTokens> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? locale,
    String deviceName = 'mock-device',
  }) async {
    _checkFailure();
    await tokenStorage.saveTokens(mockTokens);
    return mockTokens;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
    String deviceName = 'mock-device',
  }) async {
    _checkFailure();
    await tokenStorage.saveTokens(mockTokens);
    return mockTokens;
  }

  @override
  Future<AuthTokens> refresh({String deviceName = 'mock-device'}) async {
    _checkFailure();
    final newTokens = AuthTokens(
      accessToken: 'rotated-${mockTokens.accessToken}',
      expiresIn: 3600,
      refreshToken: 'rotated-${mockTokens.refreshToken}',
      tokenType: 'Bearer',
    );
    await tokenStorage.saveTokens(newTokens);
    return newTokens;
  }

  @override
  Future<void> logout({bool allDevices = false}) async {
    await tokenStorage.clearTokens();
  }

  @override
  Future<UserProfile> getProfile() async {
    _checkFailure();
    return mockProfile;
  }

  void _checkFailure() {
    if (shouldFail) {
      throw ProblemDetailsException(
        title: 'Mock Error',
        status: failureStatusCode,
        detail: 'Simulated failure for testing purpose.',
        code: failureCode,
      );
    }
  }
}
