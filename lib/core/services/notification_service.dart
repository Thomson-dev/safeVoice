import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you strictly need firebase_core here, you might need to initialize it again,
  // but usually it works if initialized in main.
  print(
    'NotificationService: Handling a background message: ${message.messageId}',
  );
}

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android channel for high importance notifications
  late AndroidNotificationChannel _androidChannel;

  bool _isInitialized = false;

  // Store the token
  String? fcmToken;

  Future<NotificationService> init() async {
    if (_isInitialized) return this;

    try {
      // 1. Request Permission
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      print(
        'NotificationService: User granted permission: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Setup Local Notifications (for foreground display)
        await _setupLocalNotifications();

        // 3. Setup Firebase Listeners
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification taps when app is in background/terminated
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from a terminated state via notification
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // 4. Get FCM Token
        fcmToken = await _firebaseMessaging.getToken();
        print('NotificationService: FCM Token: $fcmToken');

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          print('NotificationService: Token refreshed: $newToken');
          fcmToken = newToken;
        });
      }

      _isInitialized = true;
    } catch (e) {
      print('NotificationService: Error initializing - $e');
    }

    return this;
  }

  Future<String?> getDeviceToken() async {
    if (fcmToken != null) return fcmToken;
    try {
      fcmToken = await _firebaseMessaging.getToken();
      return fcmToken;
    } catch (e) {
      print('NotificationService: Error getting token: $e');
      return null;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // maintain default for iOS
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    // Create the channel on the device (Android-specific)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle local notification tap
        print(
          'NotificationService: Local notification tapped: ${details.payload}',
        );
      },
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('NotificationService: Got a message whilst in the foreground!');
    print('NotificationService: Message data: ${message.data}');

    if (message.notification != null) {
      print(
        'NotificationService: Message also contained a notification: ${message.notification}',
      );

      // Show local notification
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: android.smallIcon,
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data
              .toString(), // verify if payload can be Map? usually String
        );
      }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('NotificationService: Notification tapped! ${message.data}');
    // Logic to navigate based on data, e.g., to a chat screen
    // TODO: Implement navigation logic if needed
  }
}
