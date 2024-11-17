import 'package:flutter/material.dart';
import 'package:tflite_project/screens/home_screen.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: HomeScreen(),
        ),
      )
  );
}