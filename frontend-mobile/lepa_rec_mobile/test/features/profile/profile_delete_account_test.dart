import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lepa_rec_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lepa_rec_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/profile/data/dtos/profile_me_dto.dart';
import 'package:lepa_rec_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile delete account', () {
    testWidgets('delete account button is shown below logout section', (
      tester,
    ) async {
      final remote = _FakeProfileRemoteDataSource();
      final authLocal = _FakeAuthLocalDataSource();
      await tester.pumpWidget(
        _buildTestApp(remote: remote, authLocal: authLocal),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Delete account'), findsOneWidget);
      final logoutOffset = tester.getTopLeft(find.text('Logout'));
      final deleteOffset = tester.getTopLeft(find.text('Delete'));
      expect(deleteOffset.dy, greaterThan(logoutOffset.dy));
    });

    testWidgets('shows confirmation dialog with cancel and delete actions', (
      tester,
    ) async {
      final remote = _FakeProfileRemoteDataSource();
      final authLocal = _FakeAuthLocalDataSource();
      await tester.pumpWidget(
        _buildTestApp(remote: remote, authLocal: authLocal),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsNWidgets(2));
    });

    testWidgets('success path clears session and redirects to login', (
      tester,
    ) async {
      final remote = _FakeProfileRemoteDataSource();
      final authLocal = _FakeAuthLocalDataSource();
      await tester.pumpWidget(
        _buildTestApp(remote: remote, authLocal: authLocal),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();

      expect(authLocal.clearSessionCallCount, 1);
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('failure path shows error and keeps session', (tester) async {
      final remote = _FakeProfileRemoteDataSource(deleteStatusCode: 500);
      final authLocal = _FakeAuthLocalDataSource();
      await tester.pumpWidget(
        _buildTestApp(remote: remote, authLocal: authLocal),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();

      expect(
        find.text('Could not delete account right now. Please try again.'),
        findsOneWidget,
      );
      expect(authLocal.clearSessionCallCount, 0);
      expect(find.text('Login Screen'), findsNothing);
    });
  });
}

class _FakeProfileRemoteDataSource extends ProfileRemoteDataSource {
  _FakeProfileRemoteDataSource({this.deleteStatusCode});

  final int? deleteStatusCode;

  @override
  Future<ProfileMeDto> getMe() async {
    return const ProfileMeDto(
      userId: 'u1',
      email: 'test@sagledaj.com',
      firstName: 'Test',
      lastName: 'User',
      preferredLanguage: 'en',
      notificationEnabled: false,
      notificationTimeLocal: null,
      timeZoneId: null,
      onboardingCompleted: true,
    );
  }

  @override
  Future<void> deleteAccount() async {
    if (deleteStatusCode == null) return;
    throw DioException(
      requestOptions: RequestOptions(path: '/account'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/account'),
        statusCode: deleteStatusCode,
      ),
    );
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  int clearSessionCallCount = 0;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount++;
  }
}

Widget _buildTestApp({
  required ProfileRemoteDataSource remote,
  required AuthLocalDataSource authLocal,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    routes: {
      '/': (context) => ProfilePage(
        remoteDataSource: remote,
        authLocalDataSource: authLocal,
        openExternalLink: (_) async => true,
        onLanguageChanged: (_) {},
      ),
      '/login': (context) =>
          const Scaffold(body: Center(child: Text('Login Screen'))),
    },
  );
}
