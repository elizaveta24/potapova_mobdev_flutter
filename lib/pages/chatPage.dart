import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttermobilepotapova/main.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _textField = TextEditingController();

  List<BubbleWidget> bubbleWidgetsList = <BubbleWidget>[];

  String statusMsg;
  bool isConnected;
  IO.Socket socket;

  _ChatPageState() {
    statusMsg = 'Offline';
    isConnected = false;
    socket = IO.io(
        'ws://51.15.91.29:9000',
        IO.OptionBuilder()
            .setTransports(['websocket']) //для flutter или dart
            .disableAutoConnect() //отключить автоподключение
            .build());
    connectAndListen();
  }

  void sendMessage() async {
    MyApp.analytics
        .logEvent(name: 'Click', parameters: {'ButtonName': 'ChatButton'});
    String message = _textField.text;
    if (message.length > 0) {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var data = {'text': message, 'time': timestamp};
      socket.emit('message', json.encode(data));
      setState(() {
        bubbleWidgetsList.add(BubbleWidget(
            text: message,
            timeString: getCurrentTime(),
            isResponse: false,
            timestamp: timestamp));
      });
    }
  }

  void connectAndListen() {
    socket.onConnect((_) {
      setState(() {
        statusMsg = 'Connected';
      });
    });

    socket.on('received', (data) {
      var received = json.decode(data);
      setState(() {
        for (int i = 0; i < bubbleWidgetsList.length; i++) {
          if (bubbleWidgetsList[i].getTimestamp == received['time']) {
            bubbleWidgetsList[i] = BubbleWidget(
              text: received['text'].toString(),
              timeString: getTimeStringFromTimestamp(received['time']),
              isResponse: false,
              isReceived: true,
              timestamp: received['time'],
            );
          }
        }
      });
    });

    socket.on('response', (data) {
      print('response: ' + data);
      var received = json.decode(data);
      bubbleWidgetsList.add(BubbleWidget(
        text: received['text'].toString(),
        timeString: getTimeStringFromTimestamp(received['time'] * 1000),
        isResponse: true,
        timestamp: received['time'] * 1000,
      ));
    });

    socket.onDisconnect((_) {
      setState(() {
        statusMsg = 'Reconnecting...';
      });
    });
  }

  void connectAnd() {
    socket.connect();
  }

  String getTimeStringFromTimestamp(int timestamp) {
    DateTime currentDateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp); //создается объект DateTime,представляет 1970-01-01T00: 00: 00Z + millisecondsSinceEpoch мс в заданном часовом поясе
    int hour = currentDateTime.hour;
    int minute = currentDateTime.minute;
    String hourString = hour.toString();
    String minuteString = minute.toString();
    if (hour < 10) {
      hourString = '0${hour.toString()}';
    }
    if (minute < 10) {
      minuteString = '0${minute.toString()}';
    }
    return '$hourString:$minuteString';
  }

  String getCurrentTime() {
    String now = DateFormat('hh:mm').format(DateTime.now());
    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Bubble(
              color: Color.fromRGBO(212, 234, 244, 1.0),
              child: Text(statusMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.0)),
            ),
          ),
          Expanded(
            //дочерний элемент заполнял доступное пространство
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: ListView(
                //Прокручиваемый список виджетов, расположенных линейно.
                children: [
                  ...bubbleWidgetsList,
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Flexible(
                  //управляет тем как изгибается дочерний элемент строки
                  child: TextField(
                    controller: _textField,
                    decoration: InputDecoration(
                      //украшения для текстового поля
                      hintText: "Write message...",
                      hintStyle: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                    onPressed: sendMessage,
                    child: Icon(
                      Icons.send,
                      color: Colors.blue,
                      size: 24,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0 //тень
                    ),
                FloatingActionButton(
                    onPressed: connectAnd,
                    child: Icon(
                      Icons.connect_without_contact,
                      color: Colors.blue,
                      size: 24,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0 //тень
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleWidget extends StatelessWidget {
  final String text;
  final String timeString;
  final bool isResponse;
  final bool isReceived;
  final int timestamp;

  String get getText => this.text;
  String get getTimeString => this.timeString;
  bool get getIsResponse => this.isResponse;
  int get getTimestamp => this.timestamp;

  BubbleWidget({
    this.text,
    this.timeString,
    this.timestamp,
    this.isResponse = false,
    this.isReceived = false,
  });

  Row makeTime() {
    return Row(
        mainAxisSize:
            MainAxisSize.min, //Сколько места должно занимать строка, минимально
        children: [
          Text(
            timeString,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) => Bubble(
      alignment: (isResponse) ? Alignment.topLeft : Alignment.topRight,
      color: (isResponse) ? Colors.purpleAccent : Colors.greenAccent,
      child: Column(children: [Text(text), makeTime()]));
}
