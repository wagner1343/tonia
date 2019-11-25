import 'package:flutter/material.dart';
import 'package:tonia_client/tonia_client/ui/HomeScreen.dart';
import 'package:tonia_client/tonia_client/ui/LoginScreen.dart';
import 'package:tonia_client/tonia_client/ui/RouterScreen.dart';
import 'package:tonia_client/tonia_client/ui/misc/palletes.dart';

class ToniaClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TonIA',
      theme: ThemeData(
        buttonColor: Palletes.brown[500],
        buttonTheme: ButtonThemeData(
          buttonColor: Palletes.brown[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
          textTheme: ButtonTextTheme.primary
        ),
        primaryColor: Palletes.brown[500],
        primaryColorDark: Color(0xFF5D4037),
        primaryColorLight: Color(0xFFD7CCC8),
        accentColor: Color(0xFFFF5252),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        primarySwatch: Palletes.brown,
      ),
      routes: {
        "/": (ctx) => RouterScreen(),
        "login": (ctx) => LoginScreen(),
        "home": (ctx) => HomeScreen(),
      },
      initialRoute: "/",
    );
  }
}
