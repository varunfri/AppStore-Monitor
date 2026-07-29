import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_store_monitor/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'read') {
            return null; // Return null so SecureStorageService reads nothing
          }
          return null;
        });
  });

  testWidgets('App starts on local credentials configuration screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the configuration screen titles and fields are present.
    expect(find.text('App Store Connect'), findsWidgets);
    expect(find.text('Local Credentials Configuration'), findsOneWidget);
    expect(find.text('Issuer ID'), findsOneWidget);
    expect(find.text('Key ID'), findsOneWidget);
    expect(find.text('Private Key (.p8 contents)'), findsOneWidget);
  });
}
