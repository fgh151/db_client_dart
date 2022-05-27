
import 'dart:convert';

import 'package:http/http.dart' as http;

class AppHttpClient {
  final String _server;
  final String _scheme;

  int port = 80;
  final String _key;

  AppHttpClient(this._key, this._server, this._scheme, this.port);

  get serverUrl => _scheme + "://" + _server;
  get serverPort => port;
  get serverKey => _key;

  Map<String, String> getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'db-key': _key,
    };
  }

  Future<http.Response> post(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.post(
      uri,
      headers: getHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.patch(
      uri,
      headers: getHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.get(
      uri,
      headers: getHeaders(),
    );
  }

}