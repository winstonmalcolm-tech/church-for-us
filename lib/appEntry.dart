import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/homepage.dart";
import "package:church_stream/routes/onBoarding.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:internet_connection_checker/internet_connection_checker.dart";
import "package:provider/provider.dart";
import "package:overlay_support/overlay_support.dart";

class AppEntry extends StatefulWidget {
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final _box = Hive.box("cache_auth");
  late Widget startRoute;

  @override
  void initState() {

    InternetConnectionChecker().onStatusChange.listen((status) {
      bool hasInternet = (status == InternetConnectionStatus.connected);

        if (!hasInternet) {
          showSimpleNotification(
            const Text("No Internet"),
            background: Colors.red,
          );
        }
    });
        
    startRoute = (_box.isEmpty) ? const OnBoardingScreen() : const Home();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => (_box.isEmpty) ? Viewer.empty() : Viewer.fromMap(_box.get("cache")),
      child: OverlaySupport.global(
        child: MaterialApp(
          navigatorKey: AppEntry.navigatorKey,
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
      ),
    );
  }
}