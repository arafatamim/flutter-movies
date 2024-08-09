import 'package:flutter/foundation.dart';

@immutable
class TraktCode {
  final String deviceCode;
  final String userCode;
  final String verificationUrl;
  final int expiresIn;
  final int interval;

  const TraktCode({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUrl,
    required this.expiresIn,
    required this.interval,
  });

  @override
  String toString() {
    return 'TraktCode(deviceCode: $deviceCode, userCode: $userCode, verificationUrl: $verificationUrl, expiresIn: $expiresIn, interval: $interval)';
  }

  factory TraktCode.fromJson(Map<String, dynamic> json) => TraktCode(
        deviceCode: json['device_code'] as String,
        userCode: json['user_code'] as String,
        verificationUrl: json['verification_url'] as String,
        expiresIn: json['expires_in'] as int,
        interval: json['interval'] as int,
      );
}
