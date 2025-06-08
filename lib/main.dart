import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // ✅ الاستيراد الجديد

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// global object for accessing device screen size
late Size mq;

// كائن الإشعارات المحلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // تهيئة Firebase + الإشعارات
  await _initializeFirebase();
  await _initializeLocalNotifications(); // ✅ تهيئة الإشعارات

  // تحديد الوضع الرأسي فقط
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 19),
          backgroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );

  log('\nNotification Channel Result: $result');
}

// ✅ تهيئة flutter_local_notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// ✅ دالة لعرض إشعار (يمكنك استدعاؤها لاحقًا من أي مكان)
Future<void> showLocalNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'chats', // يجب أن يطابق ID القناة التي سجلتها
    'Chats',
    channelDescription: 'For Showing Message Notification',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'عنوان الإشعار',
    'هذا نص الإشعار',
    platformDetails,
  );
}
