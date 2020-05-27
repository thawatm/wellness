import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/models/userdata.dart';

class StateModel extends Model {
  FirebaseUser _currentUser;
  bool isLoading;
  UserProfile _userProfile;
  String _uid;

  StateModel({
    this.isLoading = false,
  });

  FirebaseUser get currentUser => _currentUser;
  UserProfile get userProfile => _userProfile;
  String get uid => _uid;

  void addUser(FirebaseUser user) {
    _currentUser = user;
    _uid = user.uid;
    isLoading = false;

    notifyListeners();
  }

  void addUserProfile(DocumentSnapshot userSn) {
    isLoading = false;
    _userProfile = UserProfile.fromSnapshot(userSn);
    notifyListeners();
  }

  void dispose() {
    _currentUser = null;
    _userProfile = null;
    isLoading = false;
    notifyListeners();
  }

  static StateModel of(BuildContext context) =>
      ScopedModel.of<StateModel>(context);
}
