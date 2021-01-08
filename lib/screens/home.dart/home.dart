import 'package:flutter/material.dart';
import 'package:web_product_unitrade/models/products.dart';
import 'package:web_product_unitrade/models/user.dart';
import 'package:web_product_unitrade/products/product_form.dart';
import 'package:web_product_unitrade/screens/authentication/wrapper.dart';
import 'package:web_product_unitrade/screens/home.dart/product_streamer.dart';
import 'package:web_product_unitrade/services/auth.dart';
import 'package:web_product_unitrade/services/database.dart';
import 'package:web_product_unitrade/shared/string.dart';
import 'package:web_product_unitrade/shared/functions.dart';

class Home extends StatefulWidget {
  final String userId;
  Home({this.userId});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  PaintMaterial paintProducts;
  WoodProduct woodSolidProducts;
  Accessories accessoriesProducts;
  Lights lightProducts;
  int currentTabIndex;
  bool viewProducts;
  double distanceBetweenInkWells = 10.0;
  //User details
  List<dynamic> roles = [];
  String firstName;
  String lastName;
  String emailAddress;
  String company;
  String phoneNumber;
  String countryOfResidence;
  String cityOfResidence;
  UserData user;
  bool adminUser = false;
  String addProductButton = 'Add New Product';
  void initState() {
    super.initState();
    _getUserData();
    viewProducts = false;
  }

  AuthService _auth = new AuthService();

  //Get user details
  //get the first name of the user
  Future _getUserData() async {
    DatabaseService databaseService = DatabaseService(uid: widget.userId);
    await databaseService.unitradeCollection
        .doc(widget.userId)
        .get()
        .then((value) {
      firstName = value.data()['firstName'];
      lastName = value.data()['lastName'];
      company = value.data()['company'];
      phoneNumber = value.data()['phoneNumber'];
      countryOfResidence = value.data()['countryOfResidence'];
      cityOfResidence = value.data()['cityOfResidence'];
      emailAddress = value.data()['emailAddress'];
      roles = value.data()['roles'];

      if (firstName != null) {
        firstName = firstName.capitalize();
      }
      if (lastName != null) {
        lastName = lastName.capitalize();
      }
      if (company != null) {
        company = company.capitalize();
      }
      setState(() {
        roles.contains('isAdmin') ? adminUser = true : adminUser = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onBackPressed();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(HOME_PAGE),
          elevation: 5.0,
          backgroundColor: Colors.amberAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          child: Text(PRODUCTS),
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductStreamer(roles: roles)));
                          },
                        ),
                        SizedBox(width: 5.0,),
                        RaisedButton(
                          child: Text(ADD_PRODUCT),
                          onPressed: adminUser ? () async {
                            addProduct();
                          }: null,
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Dailog box for exiting the website
  Future onBackPressed() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(EXIT_APP_TITLE),
            content: Text(EXIT_APP_CONTENT),
            actions: [
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(ALERT_NO),
              ),
              new FlatButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Wrapper()),
                      ModalRoute.withName('/home'));
                },
                child: Text(ALERT_YES),
              ),
            ],
          );
        });
  }

  //Add new products
  addProduct() async {
    //Will send the user to a new class where they can add a new product
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductForm(roles: roles)));
  }
}
