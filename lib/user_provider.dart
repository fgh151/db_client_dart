

import 'package:db_client_dart/user.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {

  User? user;

  bool get isLoggedIn => user != null;

  void login(User user) {
    this.user = user;
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }
}