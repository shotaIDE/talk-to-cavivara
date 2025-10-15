import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:house_worker/data/model/notification.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@riverpod
class Notifications extends _$Notifications {
  static final Logger _logger = Logger('Notifications');

  @override
  Future<List<Notification>> build() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final jsonString = remoteConfig.getString('notifications');

    if (jsonString.isEmpty) {
      _logger.info('Remote Config notifications is empty');
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final notifications =
          jsonList
              .map(
                (json) => Notification.fromJson(json as Map<String, dynamic>),
              )
              .toList()
            ..sort(
              (a, b) => b.publishedAt.compareTo(a.publishedAt),
            );

      _logger.info('Loaded ${notifications.length} notifications');
      return notifications;
    } on FormatException catch (e) {
      _logger.severe('Failed to parse notifications JSON: $e');
      return [];
    } on Exception catch (e) {
      _logger.severe('Failed to convert notifications JSON: $e');
      return [];
    }
  }
}
