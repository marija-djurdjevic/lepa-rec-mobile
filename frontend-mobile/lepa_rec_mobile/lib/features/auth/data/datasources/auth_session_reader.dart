import 'package:flutter/foundation.dart';
import 'auth_local_datasource.dart';

class AuthSessionReader {
  final AuthLocalDataSource _local;

  AuthSessionReader({AuthLocalDataSource? local})
      : _local = local ?? AuthLocalDataSource();

  Future<bool> hasSession() async {
    debugPrint('🔐 AuthSessionReader.hasSession() - reading stored refresh token...');
    final refresh = await _local.readRefreshToken();
    final hasToken = refresh != null && refresh.isNotEmpty;
    debugPrint('🔐 AuthSessionReader - stored refresh token exists: $hasToken');
    return hasToken;
  }
}
