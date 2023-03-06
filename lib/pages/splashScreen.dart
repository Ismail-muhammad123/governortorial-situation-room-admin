import 'dart:ui';

import 'package:admin/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  bool _loading = false;
  String errorText = "";
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    window.onKeyData = (final keyData) {
      if (keyData.logical == LogicalKeyboardKey.enter.keyId) {
        _login();
        return true;
      }

      /// Let event pass to other focses if it is not the key we looking for
      return false;
    };
    super.initState();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.4,
            scale: 0.1,
            fit: BoxFit.fitWidth,
            image: AssetImage(
              "images/assembly.png",
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/logo.png",
              height: 200.0,
              width: 200.0,
            ),
            Text(
              "Polls Monitor".toUpperCase(),
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.red,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.red,
                    )
                  : Container(
                      width: 400,
                      height: 250,
                      padding: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              offset: const Offset(6, 6),
                              blurRadius: 12.0),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Login".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w900,
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(
                            width: 300.0,
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              decoration: const InputDecoration(
                                label: Text("Email"),
                                icon: Icon(Icons.email),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300.0,
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock),
                                label: Text("Password"),
                              ),
                            ),
                          ),
                          errorText.isNotEmpty
                              ? Text(
                                  errorText,
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )
                              : SizedBox(),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: MaterialButton(
                              onPressed: _loading ? null : _login,
                              color: Colors.green,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _loading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _login() async {
    setState(() {
      _loading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = "Invalid email or Password";
        _loading = false;
      });
    }
  }
}
