import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:web_product_unitrade/screens/authentication/sign_in.dart';
import 'package:web_product_unitrade/screens/authentication/wrapper.dart';
import 'package:web_product_unitrade/services/auth.dart';
import 'package:web_product_unitrade/shared/constants.dart';
import 'package:web_product_unitrade/shared/string.dart';

import 'models/user.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    
  };
  runApp(App());
}

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized;
  bool _error;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    _error = false;
    _initialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: MAIN_TITLE,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.amber, accentColor: Colors.amber[200]),
        home: MyHomePage(
          title: HOME_PAGE,
        ),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => new Wrapper(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showSignInInput = false;
  double sizedBoxHeight = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
            child: Image.asset(
              'images/logo.png',
              height: 300.0,
              width: 800.0,
            ),
          ),
          Container(
            width: 300.0,
            child: RaisedButton(
              color: Colors.deepOrange[400],
              child: Text(
                SIGN_IN_TEXT,
                style: buttonStyle,
              ),
              onPressed: () {
                setState(() {
                  !showSignInInput
                      ? showSignInInput = true
                      : showSignInInput = false;
                });
              },
            ),
          ),
          showSignInInput
              ? Container(height: 200.0, width: 300.0, child: SignIn())
              : SizedBox(
                  height: 15.0,
                )
        ],
      )),
    );
  }
}
