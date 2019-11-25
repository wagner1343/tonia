import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tonia_client/tonia_client/service/AuthService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerConfirmPasswordController = TextEditingController();

  PageController pageController = PageController();

  Duration pageTransitionDuration = Duration(milliseconds: 500);
  Curve pageTransitionCurve = Curves.ease;

  bool registering = false;
  bool loggingIn = false;

  StreamSubscription userSub;

  @override
  void initState() {
    super.initState();
    userSub = FirebaseAuth.instance.onAuthStateChanged.listen((u) {
      if(u != null){
        Navigator.pushReplacementNamed(context, "home");
        userSub.cancel();
      }
    });
  }

  void loginOnPressed() async{
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      showInvalidUserPasswordSnack();
      return;
    }

    setState(() {
      loggingIn = true;
    });
    try {
      AuthService.instance.loginWithEmailAndPassword(
          emailController.text.trim(), passwordController.text);
    }
    catch (e, s){
      print(e);
      print(s);
      showInvalidUserPasswordSnack();
    }
    setState(() {
      loggingIn = false;
    });
  }

  void registerOnPressed(){
    if(registerEmailController.text.isEmpty || registerPasswordController.text.isEmpty || registerConfirmPasswordController.text.isEmpty){
      showFieldsMissingSnack();
      return;
    }
    if(registerConfirmPasswordController.text != registerPasswordController.text){
      showPasswordMismatchSnack();
      return;
    }

    setState(() {
      registering = true;
    });
    try {
      AuthService.instance.registerWithEmailAndPassword(registerEmailController.text.trim(), registerPasswordController.text);
    } catch (e, s) {
      print(e);
      print(s);
      showInvalidEmailSnack();
    }
    setState(() {
      registering = false;
    });
  }

  void animateToPage(int index){
    pageController.animateToPage(index, duration: pageTransitionDuration, curve: pageTransitionCurve);
  }

  void animateToRegisterView(){
    animateToPage(1);
  }

  void animateToLoginView(){
    animateToPage(0);
  }

  void showSnack(String text){
    ScaffoldState s = Scaffold.of(context);
    s.showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () => s.hideCurrentSnackBar(),
      ),
    ));
  }

  void showPasswordMismatchSnack(){
    showSnack("A senha e a confirmação de senha não são iguais");
  }

  void showInvalidUserPasswordSnack(){
    showSnack("Usuário ou senha inválidos");
  }

  void showFieldsMissingSnack(){
    showSnack("Preencha os campos necessários");
  }

  void showInvalidEmailSnack(){
    showSnack("Email invalido");
  }
  Widget _buildRegisterView(BuildContext ctx){
    return Container(
      constraints: BoxConstraints(
          maxWidth: 320
      ),
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: 320
        ),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: registerEmailController,
                  decoration: InputDecoration(hintText: "Email"),)
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: registerPasswordController,
                  decoration: InputDecoration(hintText: "Senha"), obscureText: true,)
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: registerConfirmPasswordController,
                  decoration: InputDecoration(hintText: "Confirmar senha"), obscureText: true,)
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: registering || loggingIn ? null : () => animateToLoginView(),
                    child: Text("Voltar"),
                  ),
                  RaisedButton(
                    onPressed: registering || loggingIn ? null : registerOnPressed,
                    child:  registering ? CircularProgressIndicator() : Text("Cadastrar"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView(BuildContext ctx){
    return  Container(
      constraints: BoxConstraints(
          maxWidth: 320
      ),
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: 320
        ),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "Email"),)
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(hintText: "Senha"), obscureText: true,)
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: registering || loggingIn ? null : () => animateToRegisterView(),
                    child: Text("Cadastre-se"),
                  ),
                  SizedBox(width: 24,),
                  RaisedButton(
                    onPressed: registering || loggingIn ? null :loginOnPressed,
                    child: loggingIn ? CircularProgressIndicator() : Text("Entrar"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: theme.primaryColor,
              child: Center(child: Text("TonIA", style: TextStyle(color: Colors.white, fontSize: 0.3 * mq.size.width),),),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 12, blurRadius: 12)]
            ),
            padding: EdgeInsets.symmetric(vertical: 64  ),
            alignment: Alignment.center,
            height: 400,
            child: PageView(
              controller: pageController,
              children: <Widget>[
               _buildLoginView(context),
                _buildRegisterView(context)
              ],
            ),
          )
        ],
      ),
    );
  }
}
