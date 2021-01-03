import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const titleTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  color: Colors.black
);

const buttonStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  color: Colors.black
);

const textInputDecoration = InputDecoration(
  fillColor: Colors.white12,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2.0)),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
  ),
);

const textStyle1 = TextStyle(fontSize: 16.0, fontFamily: 'San Francisco');