import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SoundService {
  static const platform = MethodChannel('es.eglos.mta/notifications');

  Future<List<Map<String, String>>> getSystemRingtones() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getSystemRingtones');
      return result.map((item) {
        return {
          'title': item['title'] as String,
          'uri': item['uri'] as String,
        };
      }).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get ringtones: '${e.message}'.");
      return [];
    }
  }

  Future<void> playRingtone(String uri) async {
    try {
      await platform.invokeMethod('playRingtone', {'uri': uri});
    } on PlatformException catch (e) {
      debugPrint("Failed to play ringtone: '${e.message}'.");
    }
  }

  Future<void> stopRingtone() async {
    try {
      await platform.invokeMethod('stopRingtone');
    } on PlatformException catch (e) {
      debugPrint("Failed to stop ringtone: '${e.message}'.");
    }
  }
}
