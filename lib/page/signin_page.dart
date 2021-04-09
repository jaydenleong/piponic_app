/*
 * File: signin_page.dart
 * 
 * Purpose: Defines page that users can use to login or register.
 *  
 * Authors: Mason Duan, Jayden Leong
 * 
 * Date: February 27, 2021
 */

/* This file is part of the PiPonic project: an IoT Hydroponic and Aquaponic 
 * monitoring and control system.
 *
 * PiPonic is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Foobar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PiPonic.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Pages
import './register_page.dart';
import './login_page.dart';

// Style
import '../config/style.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<SigninPage> {
  FirebaseAuth result = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    result = FirebaseAuth.instance;
    print("Current user ID is : " + result.currentUser.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'PiPonic',
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Aqua/Aero/Hydroponic System Monitoring",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Roboto')),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/logo.png',
                width: 150.0,
                height: 150.0,
              ),
            ),
            SignInButtonBuilder(
              text: 'Sign in with Email',
              icon: Icons.email,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              backgroundColor: shrineBrown900,
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: SignInButtonBuilder(
                    icon: Icons.how_to_reg,
                    text: "Create new account",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    backgroundColor: shrineBrown600)),
          ]),
    ));
  }
}
