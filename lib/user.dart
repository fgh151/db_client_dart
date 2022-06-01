import 'dart:async';
import 'dart:convert';

import 'package:db_client_dart/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String id = '';
  String email = '';
  String password = '';
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

  User setId(String id) {
    this.id = id;
    return this;
  }

  User fromJson(Map map) {
    User u = User(_client);
    u.setEmail(map["email"]).setToken(map['token']).setId(map['id']);

    return u;
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'id': id,
      };

  // get isLoggedIn => token.isNotEmpty;

  Future<bool> auth() {
    return _client.post('/api/user/auth', body: this).then((value) {
      if (value.statusCode == 200) {
        var user = fromJson(jsonDecode(value.body));
        _client.setAuthHeader(user.token);
        token = user.token;
        return SharedPreferences.getInstance().then((prefs) {
          prefs.setString("token", token);
          _client.registerDevice(prefs, userId: user.id);
          return true;
        });
      }

      return false;
    });
  }

  Future<User> register() {
    return _client
        .post('/api/user/register', body: this.toJson())
        .then((value) {
      var user = fromJson(jsonDecode(value.body));
      _client.setAuthHeader(user.token);
      token = user.token;

      return SharedPreferences.getInstance().then((prefs) {
        prefs.setString("token", token);
        _client.registerDevice(prefs, userId: user.id);
        return this;
      });
    });
  }

  Future<User> fetchUser() {
    return isLoggedIn().then((logeed) {
      return _client.get("/api/user/me").then((value) {
        var user = fromJson(jsonDecode(value.body));
        _client.setAuthHeader(user.token);
        token = user.token;
        email = user.email;
        id = user.id;
        return this;
      });
    });
  }

  static Future<bool> isLoggedIn() {
    return SharedPreferences.getInstance().then((prefs) {
      var token = prefs.getString("token");

      if (token == null) {
        return false;
      }

      if (token.isEmpty) {
        return false;
      }

      return true;
    });
  }
}
