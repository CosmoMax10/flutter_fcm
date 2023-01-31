import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

// 通知インスタンスの生成
final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

//httpでfcmを呼び出す関数
sendNotification() {
  print("sendNotificationが実行されました");
  try {
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAr7ILvo4:APA91bE7TKfa8Gvvl9ycolABPOUv4yzKHQ_rdMLpy5wMANxAqZFhH_aZSux5-TFAeDvkND0aeNzOL2bhWmmw4OUw6qOKb0J4kW8OQttJC7ssBp1Tvm0lHdhLTo-4-i8AR55IbCAXaqsu',
      },
      body: jsonEncode({
        'to':
            'fsBirEppRBqi4vBfMda_AO:APA91bF5t_zVMq2QQVRKxdjA-YM88XTqYdzyVgvAihq9JVv1wg5VGPOdA1HeHxdc4lz49JvPPbP3H6r5ivs5GsazwQFl6d_x9MmpJ_jqWuPsAZRRCBJ8d0qf-sGmtN02xq8Ws8IJkSMh',
        'priority': 'high',
        'notification': {
          'title': 'プッシュ通知',
          'body': 'ボタンがクリックされ、fcmAPIを経由して通知されました',
        }
      }),
    );
    print("ボタンが押され、http経由でfcmから通知が送られました。");
  } catch (e) {
    print(e);
  }
}

//バックグラウンドでメッセージを受け取った時のイベント(トップレベルに定義)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  flnp.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher')));

  if (notification == null) {
    return;
  }
  // 通知
  flnp.show(
      notification.hashCode,
      "${notification.title}:バックグラウンド",
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
        ),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // バックグラウンドでのメッセージ受信イベントを設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

// MyApp、MyHomePageはデフォルトから変更がないため省略

class _MyHomePageState extends State<MyHomePage> {
  String _token = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void _pushNotification() {
    print("button pressed!");
    sendNotification();
    flnp.show(
        3000,
        "ローカルのpush通知",
        "ボタンを押しました。",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    // アプリ初期化時に画面にtokenを表示
    _firebaseMessaging.getToken().then((String? token) {
      setState(() {
        _token = token!;
      });
      // コピーしやすいようにターミナルに出すためにprint
      print(token);
    });

    //フォアグラウンドでメッセージを受け取った時のイベント
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      flnp.initialize(const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      if (notification == null) {
        return;
      }
      // 通知
      flnp.show(
          notification.hashCode,
          "${notification.title}:フォアグラウンド",
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
            ),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(_token),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushNotification,
        child: const Icon(Icons.timer),
      ),
    );
  }
}
