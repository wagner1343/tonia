import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RouterScreen extends StatefulWidget {
  @override
  _RouterScreenState createState() => _RouterScreenState();
}

class _RouterScreenState extends State<RouterScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  StreamSubscription userSub;
  @override
  void initState() {
    super.initState();
    userSub = auth.onAuthStateChanged.listen((u) {
      if(u != null)
        Navigator.pushReplacementNamed(context, "home");
      else
        Navigator.pushReplacementNamed(context, "login");
      userSub.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    userSub.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
