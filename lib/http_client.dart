import 'dart:convert';

import 'package:db_client_dart/platform.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'application.dart';

class AppHttpClient {
  final String _server;
  final String _scheme;

  int port = 80;
  final String _key;

  Map<String, String> headers = {};

  AppHttpClient(this._key, this._scheme, this._server, this.port) {
    headers = {
      'Origin': 'app',
      'Content-Type': 'application/json; charset=UTF-8',
      'db-key': _key,
    };
  }

  get serverUrl => "$_scheme://$_server";

  get serverPort => port;

  get serverKey => _key;

  Map<String, String> getHeaders() {
    return headers;
  }

  void setAuthHeader(String? value) {
    if (value != null) {
      headers['Authorization'] = 'Bearer $value';
    }
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

  Future<http.Response> get(String url, {Map<String, dynamic>? body}) {
    Map<String, String> queryParameters = {};
    if (body != null) {
      body.forEach((key, value) {
        queryParameters[key] = value.toString();
      });
    }
    var uri = Uri(
        scheme: _scheme,
        host: _server,
        port: port,
        path: url,
        queryParameters: queryParameters);

    return http
        .get(
      uri,
      headers: getHeaders(),
    )
        .then((resp) {
      if (resp.statusCode == 200) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString(uri.toString(), resp.body);
        });

        return resp;
      }

      return SharedPreferences.getInstance().then((prefs) {
        var body = prefs.getString(uri.toString());
        return http.Response(body ??= '', 200);
      });
    });
  }

  Future<http.Response> delete(String url, {Object? body}) {
    var uri = Uri(scheme: _scheme, host: _server, port: port, path: url);
    return http.delete(uri, headers: getHeaders(), body: body);
  }

  registerDevice(SharedPreferences prefs, {String? userId}) {
    var params = {
      'device': DbPlatform.operatingSystem,
      'device_token': DbPlatform.getDeviceId(prefs),
      'user_id': userId ??= '' // user uuid
    };

    post('/api/device/register', body: params).then((response) {
      if (response.statusCode == 200) {
        prefs.setString(Application.uuidKey, params["device_token"]!);
      }
    });
  }
}
