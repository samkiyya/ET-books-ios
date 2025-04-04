import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformChecker {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !isWeb && Platform.isAndroid;
  static bool get isIOS => !isWeb && Platform.isIOS;

  static bool get supportsNativeAudio => !isWeb && (isAndroid || isIOS);
}
