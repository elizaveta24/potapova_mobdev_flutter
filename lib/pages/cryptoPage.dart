import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as Enc;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class LabCrypto extends StatefulWidget {
  _LabCryptoState createState() => _LabCryptoState();
}

class _LabCryptoState extends State<LabCrypto> {
  final keyField = TextEditingController();
  String _encrypt;
  String _decrypt;
  final encryptInitializeVector = Enc.IV.fromLength(16);

  Future<void> encrypt(String keyStr) async {
    var len = keyStr.length;
    if (keyStr.length < 32) {
      for (int i = 0; i < 32 - len; i++) {
        keyStr = "$keyStr ";
      }
    }
    Directory directory = await getExternalStorageDirectory();
    var encrypter = Enc.Encrypter(Enc.AES(Enc.Key.fromUtf8(keyStr),
        mode: Enc.AESMode.ctr, padding: null));
    File('${directory.path}/encryptfile.txt')
        .openWrite(mode: FileMode.write)
        .writeAll([]);

    await for (var textFromFile
        in File('${directory.path}/file.txt').openRead()) {
      String textFromFileString = Utf8Decoder().convert(textFromFile);
      var encrypted =
          encrypter.encrypt(textFromFileString, iv: encryptInitializeVector);
      File('${directory.path}/encryptfile.txt')
          .openWrite(mode: FileMode.append, encoding: utf8)
          .write(encrypted.base64);
    }
    // File('${directory.path}/file.txt').openRead().forEach((element) async {
    //   //по размеру буфера устройства
    //   print(element);
    //   var result = String.fromCharCodes(element);
    //   final key = Enc.Key.fromUtf8(keyStr);
    //   final iv = Enc.IV
    //       .fromLength(16); //вектор инициализации, случайные данные для различия
    //   final encrypter = Enc.Encrypter(Enc.AES(key, padding: null));

    //   final encrypted = encrypter.encrypt(result, iv: iv);

    //   // _encrypt = encrypted.base64.toString(); //посмотреть base64

    //   File file = File('${directory.path}/encryptfile.txt');
    //   await file.writeAsString(encrypted.base64);//Получает зашифрованные байты в виде представления Base64.
    //   // print(_encrypt);
    // });
  }

  Future<void> decrypt(String keyStr) async {
    final len = keyStr.length;
    if (keyStr.length < 32) {
      for (int i = 0; i < 32 - len; i++) {
        keyStr = "$keyStr ";
      }
    }

    Directory directory = await getExternalStorageDirectory();
    var encrypter = Enc.Encrypter(Enc.AES(Enc.Key.fromUtf8(keyStr),
        mode: Enc.AESMode.ctr, padding: null));
    File('${directory.path}/decryptfile.txt')
        .openWrite(mode: FileMode.write)
        .writeAll([]);
    await for (var textFromFile
        in File('${directory.path}/encryptfile.txt').openRead()) {
      String textFromFileString = Utf8Decoder().convert(textFromFile);
      var decrypted =
          encrypter.decrypt64(textFromFileString, iv: encryptInitializeVector);
      File('${directory.path}/decryptfile.txt')
          .openWrite(mode: FileMode.append, encoding: utf8)
          .write(decrypted);

      // _decryptedText += decrypted;
    }
    // File('${directory.path}/encryptfile.txt')
    //     .openRead()
    //     .forEach((element) async {
    //   print('el:$element');
    //   var result = String.fromCharCodes(element);
    //   final key = Enc.Key.fromUtf8(keyStr);
    //   final iv = Enc.IV.fromLength(16);

    //   final encrypter = Enc.Encrypter(Enc.AES(key, padding: null));
    //   final encryptedText = Enc.Encrypted.fromBase64(result);//Создает зашифрованный объект из строки Base64.
    //   final decrypted = encrypter.decrypt(encryptedText, iv: iv);
    //   _decrypt = decrypted;
    //   print(_decrypt);
    //   File file = File('${directory.path}/decryptfile.txt');
    //   await file.writeAsString(_decrypt);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 12, right: 12, top: 100, bottom: 12),
                  child: Container(
                    height: 60,
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.purpleAccent,
                      ),
                      child: TextField(
                          controller: keyField,
                          maxLength: 32,
                          decoration: InputDecoration(
                            //украшения для текстового поля
                            border: OutlineInputBorder(
                              //рамка контура
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            labelText: 'Введите ключ',
                          )),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: TextButton(
                          onPressed: () async {
                            await encrypt(keyField.text);
                          },
                          child: Text(
                            'Зашифровать',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple[100]),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: TextButton(
                          onPressed: () async {
                            await decrypt(keyField.text);
                          },
                          child: Text(
                            'Расшифровать',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple[100]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
