library db_client_dart;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class Db {
  late String _topic;
  late String _server;
  late String _scheme;

  late int _port;

  late String _key;

  Db(String schema, String server, int port, String topic, String key) {
    _scheme = schema;
    _topic = topic;
    _server = server + ":" + port.toString();
    _port = port;
    _key = key;
  }

  Future<StreamSubscription<Uint8List>> onMessage(void onData(event)) {
    return Socket.connect(_server + '/' + _topic + '/' + _key, _port)
        .then((socket) => socket.listen(onData));
  }

  Future<http.Response> sendMessage(Object msg) {
    String uri = _scheme + '://' + _server + '/push/' + _topic;

    return http.post(
      Uri.parse(uri),
      headers: getHeaders(),
      body: jsonEncode(msg),
    );
  }

  Future<http.Response> update(String id, Map msg) {
    String uri = _scheme + '://' + _server + '/push/' + _topic;

    msg['id'] = id;

    return http.patch(
      Uri.parse(uri),
      headers: getHeaders(),
      body: jsonEncode(msg),
    );
  }

  Future<http.Response> list() {
    String uri = _scheme + '://' + _server + '/em/list/' + _topic;

    return http.get(
      Uri.parse(uri),
      headers: getHeaders(),
    );
  }

  Map<String, String> getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'db-key': _key,
    };
  }
}
