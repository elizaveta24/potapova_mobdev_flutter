import 'dart:typed_data';
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
  String gotResponse = '';
  String gotResponse2 = '';

  Future<void> encrypt(String keyStr) async {
    var len = keyStr.length;
    if (keyStr.length < 32) {
      for (int i = 0; i < 32 - len; i++) {
        keyStr = "$keyStr ";
      }
    }

    Directory directory = await getExternalStorageDirectory();
    File('${directory.path}/encryptfile.txt')
        .openWrite(mode: FileMode.write)
        .writeAll([]);
    File('${directory.path}/file.txt')
        .openRead()
        .transform(utf8.decoder)
        .forEach((element) async {
      //по размеру буфера устройства
      print(element);

      // var result = String.fromCharCodes(element);
      final key = Enc.Key.fromUtf8(keyStr);
      final iv = Enc.IV
          .fromLength(16); //вектор инициализации, случайные данные для различия
      final encrypter = Enc.Encrypter(Enc.AES(key, padding: null));

      final encrypted = encrypter.encrypt(element, iv: iv);
      File('${directory.path}/encryptfile.txt')
          .openWrite(mode: FileMode.append)
          .write(encrypted.base64);
    });
  }

  Future<void> decrypt(String keyStr) async {
    final len = keyStr.length;
    if (keyStr.length < 32) {
      for (int i = 0; i < 32 - len; i++) {
        keyStr = "$keyStr ";
      }
    }

    Directory directory = await getExternalStorageDirectory();
    File('${directory.path}/decryptfile.txt')
        .openWrite(mode: FileMode.write)
        .writeAll([]);
    File('${directory.path}/encryptfile.txt')
        .openRead()
        .transform(utf8.decoder)
        .forEach((element) async {
      // var result = String.fromCharCodes(element);
      final key = Enc.Key.fromUtf8(keyStr);
      final iv = Enc.IV.fromLength(16);

      final encrypter = Enc.Encrypter(Enc.AES(key, padding: null));

      final decrypted = encrypter.decrypt64(element, iv: iv);
      _decrypt = decrypted;

      print(_decrypt);
      File('${directory.path}/decryptfile.txt')
          .openWrite(mode: FileMode.append)
          .write(decrypted);
    });
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
