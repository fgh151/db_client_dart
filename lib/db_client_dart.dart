library db_client_dart;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class Db {
  late String _topic;
  late String _server;
  late String _schema;

  late int _port;

  Db(String schema, String server, int port, String topic) {
    _schema = schema;
    _topic = topic;
    _server = server + ":" + port.toString();
    _port = port;
  }

  Future<StreamSubscription<Uint8List>> onMessage(void onData(event)) {
    return Socket.connect(_server, _port).then((socket) => socket.listen(onData));
  }

  Future<http.Response> sendMessage(Object msg) {
    String uri = _schema + '://' + _server + '/push/' + _topic;

    return http.post(
      Uri.parse(uri),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(msg),
    );
  }

  Future<http.Response> update(String id, Map msg) {
    String uri = _schema + '://' + _server + '/push/' + _topic;

    msg['id'] = id;

    return http.patch(
      Uri.parse(uri),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(msg),
    );
  }

  Future<http.Response> list() {
    String uri = _schema + '://' + _server + '/list/' + _topic;

    return http.get(
      Uri.parse(uri),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

}
