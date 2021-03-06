import 'dart:convert';
import 'http_client.dart';

abstract class Entity {
  Map<String, dynamic> toJson();

  String getId();

  Entity fromJson(Map json);
}

class EntityManager {
  final AppHttpClient _client;
  final String _topic;

  EntityManager(this._client, this._topic);

  void create(Entity e) {
    _client.post("/em/$_topic", body: e);
  }

  Future<Iterable> read(Object condition) {
    return _client.post("/em/find/$_topic", body: condition).then((response) {
      Iterable l = json.decode(response.body);
      return l;
    });
  }

  Future<List> list(Map<String, dynamic> condition, int limit, int offset) {
    condition["_start"] = offset;
    condition["_end"] = limit + offset;

    return _client.get("/em/list/$_topic", body: condition).then((response) {
      List<dynamic> decoded = jsonDecode(response.body);
      return decoded == null ? [] : decoded;
    });
  }

  void update(Entity e) {
    _client.patch("/em/$_topic/${e.getId()}", body: e);
  }

  void delete(Entity e) {
    _client.delete("/em/$_topic/${e.getId()}", body: e);
  }
}
