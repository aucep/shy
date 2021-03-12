import 'package:http/http.dart' as _http;
import 'sharedPrefs.dart';

class FimFicClient extends _http.BaseClient {
  final String userAgent = "Shy/0.0";
  final _http.Client _inner;
  FimFicClient(this._inner);

  Future<_http.StreamedResponse> send(_http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    request.headers['accept-encoding'] = "gzip, br";

    final sessionToken = sharedPrefs.sessionToken;
    final signingKey = sharedPrefs.signingKey;
    if (sessionToken.isNotEmpty && signingKey.isNotEmpty) {
      print("using auth");
      request.headers['cookie'] = 'session_token=$sessionToken; signing_key=$signingKey';
    }
    //im sorry my lord
    request.headers['host'] = "www.fimfiction.net";
    request.headers['referer'] = "https://www.fimfiction.net/";
    return _inner.send(request);
  }
}

final http = FimFicClient(_http.Client());
