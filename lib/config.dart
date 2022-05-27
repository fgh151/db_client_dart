import 'package:db_client_dart/http_client.dart';
import 'package:http/http.dart' as http;

class Config {
  final AppHttpClient _client;

  Config(this._client);

  Future<http.Response> getById(String id) {
    return _client.get('/config/' + id);
  }
}