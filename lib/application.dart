import 'dart:convert';
import 'dart:io';
import 'package:db_client_dart/config.dart';
import 'package:db_client_dart/storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'db_client_dart.dart';
import 'http_client.dart';

class Application {
  late String _topic;
  late String _server;
  late String _scheme;

  late int _port;

  late String _key;

  late AppHttpClient? _client;
  late Db? _db;
  late Config? _config;
  late Storage? _storage;

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

    getClient().post('/api/device/register', body:  jsonEncode(<String, String>{
        'device': kIsWeb ? 'web' : Platform.operatingSystem,
        'device_token': uid,
        'user_id': '' // user uuid
      })).then((response){
      if (response.statusCode == 200) {
        prefs.setString(uuidKey, uid);
      }
    });
  }

  AppHttpClient getClient() {
    _client ??= AppHttpClient(_key, _scheme, _server, _port);
    return _client!;
  }

  Db getDb() {
    _db ??= Db(getClient(), _topic);
    return _db!;
  }

  Config getConfig() {
    _config ??= Config(getClient());
    return _config!;
  }

  Storage getStorage() {
    _storage ??= Storage(getClient());
    return _storage!;
  }
}
