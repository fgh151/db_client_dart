
import 'dart:convert';

import 'package:http/http.dart' as http;

class AppHttpClient {
  final String _server;
  final String _scheme;

  int port = 80;
  final String _key;


  Map<String, String> headers = {};

  AppHttpClient(this._key, this._server, this._scheme, this.port) {
    headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'db-key': _key,
    };
  }

  get serverUrl => _scheme + "://" + _server;
  get serverPort => port;
  get serverKey => _key;

  Map<String, String> getHeaders() {
    return headers;
  }

  void setAuthHeader(String value) {
    headers['Authorization'] = 'Bearer $value';
  }

  Future<http.Response> post(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.post(
      uri,
      headers: getHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> postFile(String path, String filePath) {

    var uri = Uri(scheme: _scheme, host: _server, port: port, path: path);
    var request = http.MultipartRequest('POST', uri);

    return http.MultipartFile.fromPath('file', filePath).then((value) {
      request.files.add(value);
      request.headers.addAll(getHeaders());
      return request.send().then((value) => http.Response.fromStream(value));
    });
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

  Future<http.Response> delete(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.delete(
      uri,
      headers: getHeaders(),
      body: body
    );
  }

}