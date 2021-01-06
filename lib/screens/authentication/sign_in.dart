import 'package:flutter/material.dart';
import 'package:web_product_unitrade/screens/authentication/wrapper.dart';
import 'package:web_product_unitrade/services/auth.dart';
import 'package:web_product_unitrade/shared/constants.dart';
import 'package:web_product_unitrade/shared/string.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = new AuthService();
  final _formKey = new GlobalKey<FormState>();
  double sizedBoxWidth = 5.0;
  bool loading = false;
  String message = ' ';

  //Data input strings
  String email, password;
  String error;

  void initStat() {
    message = ' ';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            direction: Axis.vertical,
            spacing: 1.0,
            runSpacing: 1.0,
            children: [
              Container(
                height: 50.0,
                width: 250.0,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: USER_NAME,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                  validator: (val) => val.isEmpty ? USER_NAME_EMPTY : null,
                  onSaved: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: sizedBoxWidth,
              ),
              Container(
                height: 50.0,
                width: 250.0,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: PASSWORD,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                  obscureText: true,
                  onFieldSubmitted: (value) async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _auth
                          .signInWithUserNameandPassword(email, password);

                      print('Signing in result: $result');
                      if (result != null) {
                        if (result == 'User is verified')
                          setState(() {
                            loading = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Wrapper()));
                          });
                        else {
                          setState(() {
                            message = result;
                          });
                        }
                      }
                    }
                  },
                  validator: (val) => val.isEmpty ? PASSWORD_EMPTY : null,
                  onSaved: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),
              ),
              Container(
                child: Text(message),
              ),
              SizedBox(
                height: sizedBoxWidth,
              ),
              Container(
                width: 250.0,
                height: 50.0,
                child: RaisedButton(
                  child: Text(
                    SUBMIT,
                    style: buttonStyle,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.grey[700],
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _auth
                          .signInWithUserNameandPassword(email, password);
                      if (result != null) {
                        setState(() {
                          loading = false;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wrapper()));
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
