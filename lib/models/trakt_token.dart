class TraktToken {
  String accessToken;
  String tokenType;
  int expiresIn;
  String refreshToken;
  String scope;
  int createdAt;

  TraktToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.scope,
    required this.createdAt,
  });

  factory TraktToken.fromJson(dynamic json) => TraktToken(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        expiresIn: json['expires_in'] as int,
        refreshToken: json['refresh_token'] as String,
        scope: json['scope'] as String,
        createdAt: json['created_at'] as int,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
        'refreshToken': refreshToken,
        'scope': scope,
        'createdAt': createdAt,
      };
}
