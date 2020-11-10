import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('Login'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: Builder(builder: (BuildContext context) {
        return _PhoneSignInSection(Scaffold.of(context));
      }),
    );
  }
}

class _PhoneSignInSection extends StatefulWidget {
  _PhoneSignInSection(this._scaffold);

  final ScaffoldState _scaffold;
  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  FocusNode _textPhoneFocusNode = FocusNode();
  FocusNode _textSMSFocusNode = FocusNode();

  String _message = '';
  String _verificationId;
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return _isLoading ? _loadingView : _buildWidget;

    return ModalProgressHUD(
      child: _buildWidget,
      inAsyncCall: _isLoading,
      progressIndicator: CupertinoActivityIndicator(radius: 15),
    );
  }

  Widget get _buildWidget {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _isCodeSent ? _signInPhone : _verifyPhone,
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            _message,
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  Widget get _verifyPhone {
    FocusScope.of(context).requestFocus(_textPhoneFocusNode);
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            'ใส่หมายเลขโทรศัพท์',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
        ),
        TextFormField(
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, letterSpacing: 1.0),
          controller: _phoneNumberController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          // autofocus: true,
          focusNode: _textPhoneFocusNode,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          validator: (String value) {
            if (value.isEmpty) {
              return 'Phone number (0x-xxx-xxxx)';
            }
            return '';
          },
        ),
        SizedBox(height: 24),
        Container(
          height: 60,
          width: 200,
          child: RaisedButton(
            elevation: 7.0,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _verifyPhoneNumber();
              });
            },
            padding: EdgeInsets.all(12),
            color: AppTheme.buttonColor,
            child: Text('ขอรหัส OTP',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget get _signInPhone {
    FocusScope.of(context).requestFocus(_textSMSFocusNode);
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            'รหัส SMS 6 หลัก',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
        ),
        TextField(
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, letterSpacing: 1.0),
          controller: _smsController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          focusNode: _textSMSFocusNode,
          maxLength: 6,
        ),
        SizedBox(height: 24),
        Container(
            height: 60,
            width: 200,
            child: RaisedButton(
              elevation: 7.0,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _signInWithPhoneNumber();
                });
              },
              color: AppTheme.buttonColor,
              child: Text('ยืนยัน',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            )),
        // Container(
        //   // padding: const EdgeInsets.symmetric(vertical: 16.0),
        //   alignment: Alignment.center,
        //   child: RaisedButton(
        //       onPressed: () {
        //         setState(() {
        //           _smsController.clear();
        //           _verifyPhoneNumber();
        //         });
        //       },
        //       color: Colors.cyan[800],
        //       child: Text('ขอรหัสใหม่',
        //           style: TextStyle(color: Colors.white, fontSize: 16))),
        // ),
      ],
    );
  }

  // Exmaple code of how to veify phone number
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      try {
        await _auth.signInWithCredential(phoneAuthCredential);
        setState(() {
          _isLoading = true;
          // _message = 'Received phone auth credential: $phoneAuthCredential';
          isNewUser();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _message = '${e.code} : ${e.message}';
        });
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        _isLoading = false;
        _message = '${authException.code} : ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      widget._scaffold.showSnackBar(SnackBar(
        content:
            const Text('Please check your phone for the verification code.'),
      ));
      setState(() {
        _verificationId = verificationId;
        _isLoading = false;
        _isCodeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: '+66' + _phoneNumberController.text.substring(1),
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    try {
      final User user = (await _auth.signInWithCredential(credential)).user;
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      setState(() {
        if (user != null) {
          _isLoading = true;
          // _message = 'Successfully signed in, uid: ' + user.uid;
          _message = '';
          isNewUser();
        } else {
          _message = 'Sign in failed';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _smsController.clear();
        if (e.code == 'invalid-verification-code') {
          _message = '';
          widget._scaffold.showSnackBar(SnackBar(
            duration: Duration(seconds: 10),
            content: Text('The sms verification code is invalid'),
          ));
        } else {
          _message = e.message;
        }
      });
    }
  }

  void isNewUser() {
    ScopedModel.of<StateModel>(context).isLoading = true;
    // Navigator.pushReplacementNamed(context, '/');
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }
}
