import 'dart:convert';

import 'package:db_client_dart/http_client.dart';

class User {
  late int id;
  late String email;
  late String password;
  String token = '';

  final AppHttpClient _client;

  User(this._client);

  User setEmail(String email) {
    this.email = email;
    return this;
  }

  User setPassword(String password) {
    this.password = password;
    return this;
  }

  User setToken(String token) {
    this.token = token;
    return this;
  }

  User setId(int id) {
    this.id = id;
    return this;
  }

  User fromJson(Map map) {
    User u = User(_client);
    u.setEmail(map["email"]).setToken(map['token']).setId(map['id']);

    return u;
  }

  get isLoggedIn => token.isNotEmpty;

  Future<bool> auth() {
    return _client.post('/api/user/auth', body: this).then((value) {
      if (value.statusCode == 200) {
        var user = fromJson(jsonDecode(value.body));
        _client.setAuthHeader(user.token);
        token = user.token;
        return true;
      }

      return false;
    });
  }

  Future<User> register() {
    return _client.post('/api/user/register', body: this).then((value) {
      var user = fromJson(jsonDecode(value.body));
      _client.setAuthHeader(user.token);
      token = user.token;
      return this;
    });
  }

  Future<User> fetchUser() {
    if (isLoggedIn) {
      return _client.get("/api/user/me").then((value) {
        var user = fromJson(jsonDecode(value.body));
        _client.setAuthHeader(user.token);
        token = user.token;
        email = user.email;
        id = user.id;
        return this;
      });
    }

    return Future(() => this);
  }
}
