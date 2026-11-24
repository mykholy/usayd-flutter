class AuthTokens {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    this.tokenType = 'Bearer',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      refreshToken: json['refresh_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'expires_in': expiresIn,
    'refresh_token': refreshToken,
    'token_type': tokenType,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;
}
