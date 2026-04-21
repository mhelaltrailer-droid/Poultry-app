import 'dart:io';

/// Android emulator → host machine API
String defaultApiHost() =>
    Platform.isAndroid ? 'http://10.0.2.2:4000' : 'http://127.0.0.1:4000';
