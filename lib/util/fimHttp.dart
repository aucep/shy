import 'dart:convert' show jsonDecode, utf8;
import 'dart:math';

import 'package:brotli/brotli.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart'
    show BaseClient, BaseRequest, Client, Request, Response, StreamedResponse;
//code-splitting
import 'sharedPrefs.dart';
import 'signature.dart';

const useAuth = true;

final http = FimFicClient(Client());

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

  Future<FimFicResponse> ajaxRequest(String path, String method,
      {Map<String, String> body, bool signSet}) async {
    body ??= <String, String>{};
    if (signSet ?? true) {
      final set = SignSet.sign(data: body, path: path);
      body['signature'] = set.signature;
      body['signature_nonce'] = set.nonce;
      body['signature_timestamp'] = set.timestamp;
    }

    final start = DateTime.now();
    print('$method $path $body');

    final uri = Uri.parse('https://www.fimfiction.net/ajax/$path');
    final request = Request(method, uri);
    request.bodyFields = body;
    print(request.body ?? 'body is null');
    final resp = await Response.fromStream(await send(request));

    final elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    print('resp after $elapsed ms');

    final encoding = resp.headers['content-encoding'];
    print('encoding: $encoding'); //gzip, zlib already covered by http.dart
    String respBody;
    switch (encoding) {
      case 'br':
        respBody = utf8.decode(brotli.decodeToString(resp.bodyBytes).codeUnits);
        break;
      default:
        respBody = resp.body;
    }
    print('body: ${respBody.substring(0, min(respBody.length, 100))}');

    final type = resp.headers['content-type'];
    print('type: $type');
    if (type.startsWith('text/html')) {
      return FimFicResponse(is404: true);
    }
    final json = jsonDecode(respBody);
    return FimFicResponse(
      is404: false,
      json: json,
      setCookie: resp.headers.containsKey('set-cookie') ? resp.headers['set-cookie'] : null,
    );
  }
}

class FimFicResponse {
  final Map<String, dynamic> json;
  final String setCookie;
  final bool is404;
  const FimFicResponse({this.json, this.setCookie, this.is404});
}

Future<Document> fetchDoc(String path) async {
  print('fetching /$path');
  final start = DateTime.now();
  final resp = await http.get(Uri.parse('https://fimfiction.net/$path'));
  final elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  print('downloaded after $elapsed ms');

  print(resp.headers['content-encoding']); //gzip, zlib already covered by http.dart
  String body;
  switch (resp.headers['content-encoding']) {
    case 'br':
      body = utf8.decode(brotli.decodeToString(resp.bodyBytes).codeUnits);
      break;
    default:
      body = resp.body;
  }

  return parse(body);
}
