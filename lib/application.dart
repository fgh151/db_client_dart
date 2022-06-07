import 'package:db_client_dart/config.dart';
import 'package:db_client_dart/entity_manager.dart';
import 'package:db_client_dart/storage.dart';
import 'package:db_client_dart/user.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_client_dart.dart';
import 'http_client.dart';

class Application extends InheritedWidget {
  late String _topic;
  late String _server;
  late String _scheme;

  late int _port;

  late String _key;

  final AppHttpClient _client;
  late Db? _db;
  late Config? _config;
  late Storage? _storage;

  static const uuidKey = 'device_key';

  Application(
      String schema, String server, int port, String topic, String appKey,
      {Key? key, required super.child})
      : _client = AppHttpClient(appKey, schema, server, port),
        super(key: key) {
    _scheme = schema;
    _topic = topic;
    _server = "$server:$port";
    _port = port;
    _key = appKey;

    SharedPreferences.getInstance().then((prefs) {

      User.isLoggedIn().then((value) {
        _client.setAuthHeader(prefs.getString("token")!);
        if (value) {
          getUser().fetchUser().then((user) => _client.registerDevice(prefs, userId: user.id));

        } else {
          _client.registerDevice(prefs);
        }
      });

      _client.registerDevice(prefs);
    });
  }

  AppHttpClient getClient() {
    return _client;
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

  EntityManager getEntityManager(String topic) {
    return EntityManager(getClient(), topic);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }

  static Application of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Application>() as Application;

  User getUser() {
    return User(_client);
  }
}
