import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class SecurityService {
  String _key = "cf3f798a01432b3a";

  SecurityService();

  String encryptInformation(String data) {
    final key = utf8.encode(_key);
    final iv = utf8.encode(_key.substring(0, 16));
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: IV(iv));
    return encrypted.base64;
  }

  String decryptInformation(String encryptedData) {
    final key = utf8.encode(_key);
    final iv = utf8.encode(_key.substring(0, 16));
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: IV(iv));
    return decrypted;
  }

  bool compare(String plainData, String encryptedDataFromDB) {
    final encryptedData = encryptInformation(plainData);
    return encryptedData == encryptedDataFromDB;
  }
}
