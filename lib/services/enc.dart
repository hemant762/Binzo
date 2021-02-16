
import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8("MSguVbx44KL1rT8r8M4cgRXW8wWx8H8a");
final iv = IV.fromUtf8("h1ZuQ1renq1ashmb");

String encrypt(String text){
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(text,iv: iv);
  return encrypted.base64;
}

String decrypt(String text){
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(Encrypted.from64(text),iv: iv);
  return decrypted;
}