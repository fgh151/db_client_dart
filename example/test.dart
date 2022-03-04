import 'package:db_client_dart/db_client_dart.dart';

main() {
  var db = Db('http', 'localhost', 9090, 'test');
  
  db.sendMessage(<String, String>{
      'title': "test",
    }).then((value) {
     print(value.body);
  });

  db.onMessage((event) {print(event);});
}