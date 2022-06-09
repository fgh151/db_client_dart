import 'dart:isolate';

import 'package:db_client_dart/config.dart';
import 'package:db_client_dart/entity_manager.dart';
import 'package:db_client_dart/platrorm.dart';
import 'package:db_client_dart/storage.dart';
import 'package:db_client_dart/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'db_client_dart.dart';
import 'http_client.dart';

class Application extends InheritedWidget {
  late String _topic;
  final AppHttpClient _client;
  late Db? _db;
  late Config? _config;
  late Storage? _storage;
  User? _user;

  static const uuidKey = 'device_key';

  bool pushSubscribe;

  Application(
      String schema, String server, int port, String topic, String appKey,
      {Key? key, required super.child, this.pushSubscribe = false})
      : _client = AppHttpClient(appKey, schema, server, port),
        super(key: key) {
    _topic = topic;
    SharedPreferences.getInstance().then((prefs) {

      print("run isolate");
      Isolate.spawn(pushHandle, PushIsolateModel(DbPlatform.getDeviceId(prefs), schema, server, port ));

      var token = prefs.getString("token");
      if (token != null) {
        _client.setAuthHeader(prefs.getString("token"));
        User(_client).fetchUser().then((user) {
          _user = user;
          _client.registerDevice(prefs, userId: user.id);
        });
      } else {
        _client.registerDevice(prefs);
      }
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

  EntityManager getEntityManager({String? topic}) {
    return EntityManager(getClient(), topic ??= _topic);
  }

  @override
  bool updateShouldNotify(covariant Application oldWidget) {
    return false; // userId != oldWidget.userId;
  }

  String? get userId => _user != null ? _user!.id : null;

  static Application of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Application>() as Application;

  User getUser() {
    _user ??= User(_client);
    return _user!;
  }

  void pushHandle(PushIsolateModel model) {

    var uri = Uri(
      scheme: model.schema == 'http' ? "ws" : "wss",
      host: model.server,
      port: model.port,
      path: "/api/push/subscribe/${model.deviceId}"
    );

    print("Create channel in isolate " + uri.toString());
    var channel = WebSocketChannel.connect(uri);

    channel.stream.listen((message) {

      print("WS: " +message.toString());

    });

  }
}


class PushIsolateModel {
  final String deviceId;
  final String schema;
  final String server;
  final int port;

  PushIsolateModel(this.deviceId, this.schema, this.server, this.port);

}