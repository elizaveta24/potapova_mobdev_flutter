import 'dart:async';
import 'package:flutter/services.dart';

/// The class provide encryption and decrytion method 
class Cipher2 {
  /// the channel for cipher2
  static const MethodChannel _channel = const MethodChannel('cipher2');

  /// Encrypt data by AES algorithm with CCB Padding 7 mode, and return a
  /// base64 encoded encrypted string
  ///
  /// [plainText] is the string to be encrypted.
  ///
  /// [key] the key string, the length of it should be 128bits(16 bytes) 
  /// 
  /// [iv] the iv string, the length of it should be 128bits(16 bytes) 
  static Future<String> encryptAesCbc128Padding7(
          String plainText, String key, String iv) async =>
      await _channel.invokeMethod("Encrypt_AesCbc128Padding7", {
        "data": plainText,
        "key": key,
        "iv": iv,
      });

  /// Decrypt data by AES algorithm with CCB Padding 7 mode, and return a
  /// plain text
  ///
  /// [encryptedText] is a base64 encoded encrypted string.
  ///
  /// [key] the key string, the length of it should be 128bits(16 bytes) 
  /// 
  /// [iv] the iv string, the length of it should be 128bits(16 bytes) 
  static Future<String> decryptAesCbc128Padding7(
      String encryptedText, String key, String iv) async {
    final decrypted = await _channel.invokeMethod("Decrypt_AesCbc128Padding7", {
      "data": encryptedText,
      "key": key,
      "iv": iv,
    });
    return decrypted;
  }

  /// Return a base64 encoded nonce string. The length of nonce string is  
  /// 92bits(12 bytes) before base64 encoding
  static Future<String> generateNonce() async =>
      await _channel.invokeMethod("Generate_Nonce", {});

  /// Encrypt data by AES algorithm with GCM mode, and return a
  /// base64 encoded encrypted string
  ///
  /// [plainText] is the string to be encrypted.
  ///
  /// [key] the key string, the length of it should be 128bits(16 bytes) 
  /// 
  /// [nonce] the base64 encoded nonce string, the length of it should be 
  /// 92bits(12 bytes), which can be generated by [generateNonce()] method 
  static Future<String> encryptAesGcm128(
          String plainText, String key, String nonce) async =>
      await _channel.invokeMethod("Encrypt_AesGcm128", {
        "data": plainText,
        "key": key,
        "nonce": nonce,
      });

  /// Decrypt data by AES algorithm with GCM mode, and return a
  /// plain text
  ///
  /// [encryptedText] is a base64 encoded encrypted string.
  ///
  /// [key] the key string, the length of it should be 128bits(16 bytes) 
  /// 
  /// [nonce] the base64 encoded nonce string, the length of it should be 92bits(12 bytes), 
  /// which can be generated by [generateNonce()] method 
  static Future<String> decryptAesGcm128(
      String encryptedText, String key, String nonce) async {
    final decrypted = await _channel.invokeMethod("Decrypt_AesGcm128", {
      "data": encryptedText,
      "key": key,
      "nonce": nonce,
    });
    return decrypted;
  }
}