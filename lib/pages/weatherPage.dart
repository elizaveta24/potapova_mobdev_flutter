import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import '../main.dart';

class Lab3 extends StatefulWidget {
  Lab3State createState() {
    return Lab3State();
  }
}

class Lab3State extends State<Lab3> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [
    WebViewWeather(),
    HTML(),
    Celcium(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_browser),
            label: 'Web View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'HTML',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Погода',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class WebViewWeather extends StatefulWidget {
  _WebViewWeatherState createState() => _WebViewWeatherState();
}

class _WebViewWeatherState extends State<WebViewWeather> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'https://yandex.ru/pogoda/moscow',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        );
      }),
    );
  }
}

class HTML extends StatefulWidget {
  _HTMLState createState() => _HTMLState();
}

String htmlData = "";

class _HTMLState extends State<HTML> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 31),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                child: Icon(Icons.arrow_downward),
                onPressed: () async {
                  await _loadData();
                }),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(child: Text("$htmlData", style: TextStyle(fontSize: 12))),
          ],
        )));
  }

  _loadData() async {
    var response = await http.get(Uri.parse("https://yandex.ru/pogoda/moscow"));
    if (response.statusCode == 200) {
      setState(() {
        htmlData = response.body;
      });
    }
  }
}

class Celcium extends StatefulWidget {
  _CelciumState createState() => _CelciumState();
}

class _CelciumState extends State<Celcium> {
  String data = '';
  bool cmbscritta = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 31),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              child: Icon(Icons.arrow_downward),
              onPressed: () async {
                await _loadData2();
                setState(() {
                  cmbscritta = true;
                });
              },
            ),
          ),
        ),
        body: Center(
            child: Container(
          child: cmbscritta
              ? Text("Текущая температура  $data° C ",
                  style: TextStyle(fontSize: 22))
              : Text(""),
        )));
  }

  _loadData2() async {
    var response = await http.get(Uri.parse("https://yandex.ru/pogoda/moscow"));
    if (response.statusCode == 200) {
      var document = parse(response.body); //в document
      setState(() {
        data = document
            .getElementsByClassName('temp__value temp__value_with-unit')[0]
            .text;
      });
    }
  }
}
