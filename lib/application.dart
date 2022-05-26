import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'db_client_dart.dart';

class Application {
  late String _topic;
  late String _server;
  late String _scheme;

  late int _port;

  late String _key;

  late Db? _db;

  static const uuidKey = 'device_key';

  Application(
      String schema, String server, int port, String topic, String key) {
    _scheme = schema;
    _topic = topic;
    _server = server + ":" + port.toString();
    _port = port;
    _key = key;

    SharedPreferences.getInstance().then((prefs) {
      var uid = prefs.getString(uuidKey);
      if (uid == null) {
        _registerToken(prefs);
      }
    });
  }

  _registerToken(SharedPreferences prefs) {
    var uuid = const Uuid();
    var uid = uuid.v4();

    http.post(
      Uri.parse(_scheme + '://' + _server + '/api/device/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'db-key': '123'
      },
      body: jsonEncode(<String, String>{
        'device': kIsWeb ? 'web' : Platform.operatingSystem,
        'device_token': uid,
      }),
    ).then((response){
      if (response.statusCode == 200) {
        prefs.setString(uuidKey, uid);
      }
    });
  }

  Db getDb() {
    _db ??= Db(_scheme, _server, _port, _topic, _key);
    return _db!;
  }
}
