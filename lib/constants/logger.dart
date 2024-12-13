class Logger {
  static bool _debugMode = true;

  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  static void error(String message, [dynamic error]) {
    if (_debugMode) {
      print('🔴 Error: $message');
      if (error != null) {
        print('Details: $error');
        if (error is Error) {
          print('Stack trace: ${error.stackTrace}');
        }
      }
    }
  }

  static void info(String message) {
    if (_debugMode) {
      print('ℹ️ Info: $message');
    }
  }

  static void warning(String message) {
    if (_debugMode) {
      print('⚠️ Warning: $message');
    }
  }

  static void success(String message) {
    if (_debugMode) {
      print('✅ Success: $message');
    }
  }
}
