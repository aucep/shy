import 'dart:convert' show jsonDecode, utf8;

import 'package:brotli/brotli.dart';
import 'package:http/http.dart'
    show BaseClient, BaseRequest, Client, Request, Response, StreamedResponse;
//code-splitting
import 'sharedPrefs.dart';
import 'signature.dart';

const useAuth = true;

class FimFicClient extends BaseClient {
  final String userAgent = "Shy/0.0";
  final Client _inner;
  FimFicClient(this._inner);

  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    request.headers['accept-encoding'] = 'gzip, br';

    final sessionToken = sharedPrefs.sessionToken;
    final signingKey = sharedPrefs.signingKey;
    if (useAuth && sessionToken.isNotEmpty && signingKey.isNotEmpty) {
      print('using auth');
      request.headers['cookie'] = 'session_token=$sessionToken; signing_key=$signingKey';
    }
    //im sorry my lord
    request.headers['host'] = 'www.fimfiction.net';
    request.headers['referer'] = 'https://www.fimfiction.net/';
    return _inner.send(request);
  }

  Future<dynamic> ajaxRequest(String path, String method, {Map<String, String> body}) async {
    body ??= Map<String, String>.of({});
    final set = SignSet.sign(data: body, path: path);
    body['signature'] = set.signature;
    body['signature_nonce'] = set.nonce;
    body['signature_timestamp'] = set.timestamp;

    final start = DateTime.now();
    print('$method $path $body');

    final request = Request(method, Uri.parse('https://www.fimfiction.net/ajax/$path'));
    request.bodyFields = body;
    final resp = await Response.fromStream(await send(request));

    final elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    print('resp after $elapsed ms');

    print(resp.headers['content-encoding']); //gzip, zlib already covered by http.dart
    String respBody;
    switch (resp.headers['content-encoding']) {
      case "br":
        respBody = utf8.decode(brotli.decodeToString(resp.bodyBytes).codeUnits);
        break;
      default:
        respBody = resp.body;
    }
    return jsonDecode(respBody);
  }
}

final http = FimFicClient(Client());
