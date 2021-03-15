import 'dart:convert' show Encoding;

import 'package:http/http.dart' show BaseClient, Client, StreamedResponse, BaseRequest, Response;
import 'sharedPrefs.dart';

const useAuth = true;

class FimFicClient extends BaseClient {
  final String userAgent = "Shy/0.0";
  final Client _inner;
  FimFicClient(this._inner);

  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    request.headers['accept-encoding'] = "gzip, br";

    final sessionToken = sharedPrefs.sessionToken;
    final signingKey = sharedPrefs.signingKey;
    if (useAuth && sessionToken.isNotEmpty && signingKey.isNotEmpty) {
      print("using auth");
      request.headers['cookie'] = 'session_token=$sessionToken; signing_key=$signingKey';
    }
    //im sorry my lord
    request.headers['host'] = "www.fimfiction.net";
    request.headers['referer'] = "https://www.fimfiction.net/";
    return _inner.send(request);
  }

  Future<Response> postSigned(url, {Map<String, String> headers, body, Encoding encoding}) {
    body ??= {};
    return _inner.post(url, headers: headers, body: body, encoding: encoding);
  }
}

final http = FimFicClient(Client());
