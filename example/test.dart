import 'package:db_client_dart/application.dart';
import 'package:db_client_dart/entity_manager.dart';
import 'package:flutter/material.dart';

class TestEntity extends Entity {
  @override
  Entity fromJson(String json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  String getId() {
    // TODO: implement getId
    throw UnimplementedError();
  }

  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var app = Application('http', 'localhost', 9090, 'test', 'db-key');

    print(app);

    app.getEntityManager("test").read({"id": 1}).then((value) => {print(value)});

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text("test"),
            ),
            body: Text("test")
            // MainScreen(),
            ));
  }
}
