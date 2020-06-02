// Imports the Flutter Driver API.
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Join a Room', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final enterRoomNameTextField = find.byValueKey('enter-room-name');
    final joinButton = find.byValueKey('join-button');
    final hangupButton = find.byValueKey('hangup-button');
    final waitForParticipantText = find.byValueKey('text-wait');
    final publisherWidget = find.byValueKey('publisher');
    final localParticipantVideo = find.byValueKey('Twilio_LocalParticipant');
    final cameraButton = find.byValueKey('camera-button');
    final microphoneButton = find.byValueKey('microphone-button');
    final switchCameraButton = find.byValueKey('switch-camera-button');
    final addPersonButton = find.byValueKey('add-person-button');
    final videoOffIcon = find.byValueKey('videocam-off-icon');
    final microphoneOffIcon = find.byValueKey('microphone-off-icon');
    final roomName = 'e2e-test';
    final androidPackageName = 'twilio.flutter.programmable_video_example';
    final iosPackageName = 'twilioflutterProgrammableVideoExample';

    FlutterDriver driver;
    ProcessResult micPermResult;
    ProcessResult camPermResult;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      // Grant permissions for microphone and camera for Android and iOS
      final envVars = Platform.environment;
      if (envVars['ANDROID_SDK_ROOT'] == null && envVars['APPLESIMUTILS_PATH'] == null) {
        throw Exception('ANDROID_SDK_ROOT and APPLESIMUTILS_PATH can\'t be null. Please set one of them.');
      }

      if (envVars['APPLESIMUTILS_PATH'] != null && !Platform.isMacOS) {
        throw Exception('You can run flutter drive for iOS only on a MacOS.');
      }

      // Running for Android
      if (envVars['ANDROID_SDK_ROOT'] != null) {
        String adbPath;
        if (Platform.isLinux || Platform.isMacOS || Platform.isFuchsia) {
          adbPath = '${envVars['ANDROID_SDK_ROOT']}/platform-tools/adb';
        }
        if (Platform.isWindows) {
          adbPath = '${envVars['ANDROID_SDK_ROOT']}\\platform-tools\\adb.exe';
        }
        if (adbPath == null) {
          throw Exception('adbPath equals null, your operating system id: ${Platform.operatingSystem}');
        }
        micPermResult = await Process.run(adbPath, ['shell', 'pm', 'grant', androidPackageName, 'android.permission.RECORD_AUDIO']);
        camPermResult = await Process.run(adbPath, ['shell', 'pm', 'grant', androidPackageName, 'android.permission.CAMERA']);
      }

      // Running for iOS
      // https://github.com/wix/AppleSimulatorUtils#usage
      if (envVars['APPLESIMUTILS_PATH'] != null) {
        micPermResult = await Process.run('applesimutils', ['--booted', '--bundle', iosPackageName, '--setPermissions', 'camera=YES']);
        camPermResult = await Process.run('applesimutils', ['--booted', '--bundle', iosPackageName, '--setPermissions', 'microphone=YES']);
      }

      // Exit when permission are not granted
      if (micPermResult.exitCode != 0) {
        throw Exception('Unable to grant microphone permission: ${micPermResult.stderr}');
      }
      if (camPermResult.exitCode != 0) {
        throw Exception('Unable to grant camera permission: ${camPermResult.stderr}');
      }

      // Let's connect the driver now
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('sould have started up the app and have an empty room field', () async {
      // Use the `driver.getText` method to verify the field is empty
      expect(await driver.getText(enterRoomNameTextField), '');
    });

    test('should enter room name', () async {
      // Enter a room name in the text field
      await driver.tap(enterRoomNameTextField);
      await driver.enterText(roomName);
      await driver.waitFor(find.text(roomName));
      expect(await driver.getText(enterRoomNameTextField), roomName);
    });

    test('should join the room', () async {
      // Enter a room name in the text field
      await driver.tap(joinButton);
      // Needed for stuff wrapped in animations, otherwise it can't be found during the tests
      await driver.runUnsynchronized(() async {
        await driver.waitFor(waitForParticipantText);
        await driver.waitFor(publisherWidget);
        await driver.waitFor(localParticipantVideo);
        await driver.waitFor(cameraButton);
        await driver.waitFor(microphoneButton);
        await driver.waitFor(hangupButton);
        await driver.waitFor(switchCameraButton);
        await driver.waitFor(addPersonButton);
      });
    });

    test('should be able to switch camera off and on again', () async {
      await driver.runUnsynchronized(() async {
        await driver.tap(cameraButton);
        await driver.waitFor(videoOffIcon);
        await driver.tap(cameraButton);
        await driver.waitForAbsent(videoOffIcon);
      });
    });

    test('should be able to switch microphone off and on again', () async {
      await driver.runUnsynchronized(() async {
        await driver.tap(microphoneButton);
        await driver.waitFor(microphoneOffIcon);
        await driver.tap(microphoneButton);
        await driver.waitForAbsent(microphoneOffIcon);
      });
    });

    test('should hangup and leave the room', () async {
      await driver.runUnsynchronized(() async {
        await driver.tap(hangupButton);
        await driver.waitFor(find.text(roomName));
      });
    });
  });
}
