import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttermobilepotapova/main.dart';
import 'package:crypto/crypto.dart';

class JWT extends StatefulWidget {
  State<StatefulWidget> createState() => _JWTState();
}

class _JWTState extends State<JWT> {
  final HttpClient client = HttpClient();
  TextEditingController usernameTextFieldController = TextEditingController();
  TextEditingController passwordTextFieldController = TextEditingController();

  String token = '';
  String responseText = '';
  Uint8List
      responseImage; //Список 8-битовых целых чисел без знака фиксированной длины

  _JWTState() {
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  }

  Widget _ImageWrapper() {
    if (responseImage == null) {
      return LinearProgressIndicator();
    }
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit
                .cover, //Как ящик должен быть вписан в другой ящик  покрывает всю целевую рамку.
            image: MemoryImage(responseImage)),
        //Создает объект, который декодирует [Uint8List] как изображение
      ),
    );
  }

  void getToken() {
    MyApp.analytics.logEvent(
        name: 'ButtonClick', parameters: {'ButtonName': 'GetTokenButton'});

    var username = usernameTextFieldController.text;
    var password = passwordTextFieldController.text;
    var hashedPassword = sha256.convert(utf8.encode(password)).toString();

    client
        .getUrl(Uri.parse(
            'https://51.15.91.29/potapova/jwt/auth?username=$username&hashed_password=$hashedPassword'))
        .then((HttpClientRequest request) {
      // Optionally set up headers...
      // Optionally write to the request object...
      // Then call close.
      print(request);
      return request.close();
    }).then((HttpClientResponse response) {
      // Process the response.
      if (response.statusCode == 200) {
        response.listen((event) {
          String responseString = String.fromCharCodes(
              event); // //возвращает строку, созданную из указанной последовательности значений единиц кода UTF-16
          setState(() {
            token = json.decode(responseString)['token'];
            print(token);
          });
        });
      } else {
        response.listen((event) {
          setState(() {
            responseText = String.fromCharCodes(
                event); // //возвращает строку, созданную из указанной последовательности значений единиц кода UTF-16
            responseImage = null;
            token = '';
          });
        });
      }
    });
  }

  void getProtected() {
    client
        .getUrl(Uri.parse(
            'https://51.15.91.29/potapova/jwt/protected?token=$token'))
        .then((HttpClientRequest request) {
      // Optionally set up headers...
      // Optionally write to the request object...
      // Then call close.
      return request.close();
    }).then((HttpClientResponse response) {
      // Process the response.
      if (response.statusCode != 200) {
        response.listen((event) {
          String responseString = String.fromCharCodes(
              event); //возвращает строку, созданную из указанной последовательности значений единиц кода UTF-16
          setState(() {
            responseText = responseString;
          });
        });
      } else {
        String gotResponse = '';
        response.forEach((element) {
          gotResponse += String.fromCharCodes(
              element); ////возвращает строку, созданную из указанной последовательности значений единиц кода UTF-16
        }).then((value) {
          var jsonDecoded = json.decode(gotResponse);
          String message = jsonDecoded['message'];
          String time = DateTime.fromMicrosecondsSinceEpoch(
                  jsonDecoded['timestamp'].toInt() * 1000000)
              .toString();
          setState(() {
            responseText = '"message": "$message"\n"time":"$time"\n"photo":';
            try {
              responseImage = base64.decode(jsonDecoded['image']);
              print(responseImage);
            } catch (e) {
              print(e);
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
            child: Column(
      children: [
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(12),
            child: Text('Токен: $token', textAlign: TextAlign.center)),
        TextField(
            controller: usernameTextFieldController,
            decoration: InputDecoration(
              hintText: "Username",
            )),
        TextField(
           obscureText: true,
            controller: passwordTextFieldController,
            decoration: InputDecoration(
              hintText: "Password",
              
            )),
        ElevatedButton(onPressed: getToken, child: Text('Получить токен')),
        ElevatedButton(onPressed: getProtected, child: Text('Получить фото')),
        Container(
            child: Column(
          children: [
            Text(
              responseText,
              textAlign: TextAlign.center,
            ),
            _ImageWrapper(),
          ],
        )),
      ],
    )));
  }
}
