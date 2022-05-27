library db_client_dart;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'http_client.dart';

class Db {
  final AppHttpClient _client;
  String topic;

  Db(this._client, this.topic);

  Future<StreamSubscription<Uint8List>> onMessage(void onData(event)) {
    return Socket.connect(_client.serverUrl + '/em/subscribe/' + topic + '/' + _client.serverKey,
            _client.serverPort)
        .then((socket) => socket.listen(onData));
  }

  Future<http.Response> sendMessage(Object msg) {
    return _client.post('/em/' + topic, body: msg);
  }

  Future<http.Response> update(String id, Map msg) {
    msg['id'] = id;
    return _client.post('/em/' + topic + '/' + id, body: msg);
  }

  Future<http.Response> list() {
    return _client.get('/em/list/' + topic);
  }
}
