import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();
  static const _tokenKey = 'push_fcm_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ProfileRemoteDataSource _profileRemote = ProfileRemoteDataSource();
  final AuthLocalDataSource _authLocal = AuthLocalDataSource();

  bool _initialized = false;
  bool _firebaseReady = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
    } catch (e) {
      _firebaseReady = false;
      debugPrint('[Push] Firebase init skipped/failed: $e');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission();
      debugPrint(
        '[Push] Permission status: '
        'auth=${permission.authorizationStatus.name} '
        'alert=${permission.alert} sound=${permission.sound} badge=${permission.badge}',
      );

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
        debugPrint('[Push] FCM token acquired (len=${token.length}).');
      } else {
        debugPrint('[Push] FCM token is empty/null.');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (newToken.isEmpty) return;
        await _storage.write(key: _tokenKey, value: newToken);
        debugPrint('[Push] Token refreshed (len=${newToken.length}).');
        await registerCurrentTokenIfAuthenticated();
      });
    } catch (e) {
      debugPrint('[Push] Permission/token init failed: $e');
    }
  }

  Future<void> registerCurrentTokenIfAuthenticated() async {
    if (!_firebaseReady) return;

    final accessToken = await _authLocal.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('[Push] Skip register: no access token.');
      return;
    }

    // Always prefer the live FCM token. Cached token can be stale after reinstall.
    final liveToken = await FirebaseMessaging.instance.getToken();
    final cachedToken = await _storage.read(key: _tokenKey);
    final token = (liveToken != null && liveToken.isNotEmpty)
        ? liveToken
        : cachedToken;
    if (token == null || token.isEmpty) {
      debugPrint('[Push] Skip register: no FCM token.');
      return;
    }

    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint(
        '[Push] Registering token (platform=${_platformValue()}, len=${token.length})...',
      );
      await _profileRemote.registerPushToken(
        token: token,
        platform: _platformValue(),
      );
      debugPrint('[Push] Token registered.');
      await logDiagnostics();
    } catch (e) {
      debugPrint('[Push] Token register failed: $e');
      await logDiagnostics();
    }
  }

  Future<void> unregisterCurrentTokenIfAny() async {
    if (!_firebaseReady) return;

    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return;

    try {
      await _profileRemote.unregisterPushToken(token: token);
      debugPrint('[Push] Token unregistered.');
    } catch (e) {
      debugPrint('[Push] Token unregister failed: $e');
    }
  }

  String _platformValue() {
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> logDiagnostics() async {
    try {
      final accessToken = await _authLocal.readAccessToken();
      final localToken = await _storage.read(key: _tokenKey);
      final liveToken = _firebaseReady
          ? await FirebaseMessaging.instance.getToken()
          : null;

      debugPrint(
        '[Push][Diag] auth=${(accessToken != null && accessToken.isNotEmpty)} '
        'localTokenLen=${localToken?.length ?? 0} '
        'liveTokenLen=${liveToken?.length ?? 0} '
        'platform=${_platformValue()}',
      );

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      final me = await _profileRemote.getMe();
      debugPrint(
        '[Push][Diag] profile '
        'notificationEnabled=${me.notificationEnabled} '
        'notificationTimeLocal=${me.notificationTimeLocal ?? 'null'} '
        'timeZoneId=${me.timeZoneId ?? 'null'}',
      );
    } catch (e) {
      debugPrint('[Push][Diag] failed: $e');
    }
  }
}
