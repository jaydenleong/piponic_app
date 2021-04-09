/*
 * File: main.dart
 * 
 * Purpose: Entry point for the PiPonic mobile application.
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

// Libraries
import 'package:aquaponic_monitoring_app/page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splashscreen/splashscreen.dart';

// Pages
import './page/signin_page.dart';
import './page/home_page.dart';

// Widgets
import './widget/bottom_bar.dart';

// Configuration
import './config/style.dart';

// Entry point into the entire application
void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildShrineTheme(),
      title: 'Aqaponics Monitoring',
      home: MySplashPage(),
    );
  }
}

class MySplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User result = FirebaseAuth.instance.currentUser;

    return new SplashScreen(
      navigateAfterSeconds: result != null ? MyHomePage() : SigninPage(),
      seconds: 2,
      title: new Text(
        'PiPonic',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
      ),
      image: Image.asset('assets/logo.png', fit: BoxFit.scaleDown),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: () => {},
      loaderColor: Colors.red,
    );
  }
}
