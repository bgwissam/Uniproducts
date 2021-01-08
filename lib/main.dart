import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:web_product_unitrade/screens/authentication/sign_in.dart';
import 'package:web_product_unitrade/screens/authentication/wrapper.dart';
import 'package:web_product_unitrade/services/auth.dart';
import 'package:web_product_unitrade/shared/constants.dart';
import 'package:web_product_unitrade/shared/loading.dart';
import 'package:web_product_unitrade/shared/string.dart';

import 'models/user.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // developer.log('${Firebase.apps.length}', name: 'main.dart');
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.dumpErrorToConsole(details);
  // };
  runApp(App());
}

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Text('An Error Occurred'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamProvider<UserData>.value(
              value: AuthService().user,
              child: MaterialApp(
                title: MAIN_TITLE,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    primarySwatch: Colors.amber,
                    accentColor: Colors.amber[200]),
                home: MyHomePage(
                  title: HOME_PAGE,
                ),
                routes: <String, WidgetBuilder>{
                  '/home': (BuildContext context) => new Wrapper(),
                },
              ),
            );
          }
          return MaterialApp(
            title: MAIN_TITLE,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.red, accentColor: Colors.red[200]),
            home: Loading(),
          );
        });
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
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                child: Image.asset(
                  'images/logo.png',
                  height: 300.0,
                  width: 800.0,
                ),
              ),
            ),
            Center(
              child: Container(
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
            ),
            showSignInInput
                ? Center(
                    child:
                        Container(height: 250.0, width: 300.0, child: SignIn()))
                : Center(
                    child: SizedBox(
                      height: 15.0,
                    ),
                  )
          ],
        ),
      )),
    );
  }
}
