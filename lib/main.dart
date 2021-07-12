import 'package:flutter/material.dart';
import 'package:fluttermobilepotapova/pages/cryptoPage.dart';
import 'package:fluttermobilepotapova/pages/chatPage.dart';
import 'package:fluttermobilepotapova/pages/weatherPage.dart';
import 'package:fluttermobilepotapova/pages/JWTPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //вам необходимо вызвать собственный код, ensureInitialized()чтобы убедиться, что у вас есть экземпляр WidgetsBinding.
  await Firebase
      .initializeApp(); //инициализирует экземпляр firebase и возвращает созданное приложение
  runApp(MyApp());
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics =
      FirebaseAnalytics(); // для отслеживания событий
  // static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
  //     analytics:
  //         analytics); //для отслеживания изменений вкладки

  static String _title = 'Flutter Mobile Dev';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: MyHomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyHomePage extends StatelessWidget {
  // const MyHomePage() : super();

  Future<void> _sendEvent(int pageNum) async {
    await MyApp.analytics
        .setCurrentScreen(screenName: 'Page #$pageNum'); //текущий экран
    await MyApp.analytics.logEvent(
      name: 'page_change',
      parameters: {'page': pageNum},
    );
  }

  @override
  Widget build(BuildContext context) {
    MyApp.analytics
        .logAppOpen(); //регистрирует стандартное событие открытия приложения
    final PageController controller = PageController(initialPage: 0);
    return PageView(
      onPageChanged: (int pugeNum) async {
        await _sendEvent(pugeNum);
      },
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[
        Lab3(),
        LabCrypto(),
        ChatPage(),
        JWT(),
        Center(
          child: Text('Third Page'),
        )
      ],
    );
  }
}
