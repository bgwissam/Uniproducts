import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_product_unitrade/models/user.dart';
import 'package:web_product_unitrade/screens/home.dart/home.dart';
import 'package:web_product_unitrade/services/auth.dart';
import 'package:web_product_unitrade/shared/loading.dart';


import 'authenticate.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
 
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context) ?? null;
    
    if (userData == null) {
      return Loading();
    } else {
      return Home(userId: userData.uid,);
    }
  }
}
