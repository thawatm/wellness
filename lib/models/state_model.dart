import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StateModel extends Model {
  FirebaseUser _currentUser;
  bool isLoading;

  StateModel({
    this.isLoading = false,
  });

  FirebaseUser get currentUser => _currentUser;

  void addUser(FirebaseUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void dispose() {
    _currentUser = null;
    notifyListeners();
  }

  static StateModel of(BuildContext context) =>
      ScopedModel.of<StateModel>(context);
}
