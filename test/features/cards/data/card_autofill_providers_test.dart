import 'package:cardfolio_app/features/cards/data/card_autofill_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('cardfolio/text_recognition');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'rejects a blank image path without invoking the platform channel',
    () async {
      var callCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            callCount++;
            return 'unexpected';
          });

      await expectLater(
        const MethodChannelCardTextRecognizer().recognize('  \n  '),
        throwsA(
          isA<PlatformException>()
              .having((error) => error.code, 'code', 'invalid_path')
              .having((error) => error.message, 'message', '图片路径为空'),
        ),
      );
      expect(callCount, 0);
    },
  );

  test(
    'trims the image path and parses the recognized platform text',
    () async {
      MethodCall? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            received = call;
            return '上海交通卡\nSH-2026-001\n发行 2026';
          });

      final result = await const MethodChannelCardTextRecognizer().recognize(
        '  C:/cards/front.jpg  ',
      );

      expect(received?.method, 'recognize');
      expect(received?.arguments, <String, Object?>{
        'imagePath': 'C:/cards/front.jpg',
      });
      expect(result.rawText, '上海交通卡\nSH-2026-001\n发行 2026');
      expect(result.name, '上海交通卡');
      expect(result.code, 'SH-2026-001');
    },
  );
}
