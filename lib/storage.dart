import 'package:db_client_dart/http_client.dart';
import 'package:http/http.dart' as http;

class Storage {
  final AppHttpClient _client;

  Storage(this._client);

    Future<http.Response> saveFile(String filePath) async {
    return _client.postFile('/api/storage', filePath);
  }
}