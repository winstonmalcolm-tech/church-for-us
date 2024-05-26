import 'package:church_stream/firebase_options.dart';
import 'package:church_stream/routes/homepage.dart';
import 'package:church_stream/routes/onBoarding.dart';
import 'package:church_stream/services/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:church_stream/models/viewer.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (message.notification != null) {
      NotificationService.displayNotification(message);

    }
}


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await Hive.initFlutter();
  await FirebaseMessaging.instance.requestPermission();

  await NotificationService.getPerimission();

  NotificationService.initializeLocalNotification();

  FirebaseMessaging.instance.getInitialMessage();
  NotificationService.listenMessageInForeground();
  FirebaseMessaging.onBackgroundMessage((message) => firebaseMessagingBackgroundHandler(message));


  final _box = await Hive.openBox("cache_auth");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _box = Hive.box("cache_auth");
  late Widget startRoute;

  @override
  void initState() {
        
    startRoute = (_box.isEmpty) ? const OnBoardingScreen() : const Home();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => (_box.isEmpty) ? Viewer.empty() : Viewer.fromMap(_box.get("cache")),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 156, 120, 9)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // 1
        ),
        ),
        home: startRoute,
      ),
    );
  }
}
