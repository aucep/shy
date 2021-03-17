import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
//code-splitting
import 'sharedPrefs.dart';

class SignSet {
  final String signature, nonce, timestamp;
  SignSet({this.signature, this.nonce, this.timestamp});

  static SignSet sign({Map<String, String> data, String path}) {
    final nonce = computeNonce();
    final String timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
    path = '/ajax/' + path;

    final seq = [
      nonce,
      timestamp,
      base64Encode(path.codeUnits),
      encodeMap(data),
    ].join('|');

    final signingKey = sharedPrefs.signingKey;
    final hmac = Hmac(sha256, base64.decode(signingKey));

    return SignSet(
      signature: base64.encode(hmac.convert(seq.codeUnits).bytes),
      nonce: nonce,
      timestamp: timestamp,
    );
  }

  static String computeNonce() {
    final rnd = Random.secure();
    final charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
    return Iterable.generate(24, (_) => charset[rnd.nextInt(charset.length)]).join();
  }

  //https://stackoverflow.com/questions/10247073/urlencoding-in-dart lol
  static String encodeMap(Map data) => data.keys
      .map(
        (key) => '${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key])}',
      )
      .join('&');
}
