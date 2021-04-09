/*
 * File: home_page.dart
 *
 * Purpose: Home page for the PiPonic mobile application.
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
import 'dart:async';

import 'package:aquaponic_monitoring_app/page/add_system_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pages
import './status_page.dart';
import './config_page.dart';
import './user_page.dart';
import './chart_page.dart';

// Widgets
import '../widget/bottom_bar.dart';

// Utilities
import '../utils/push_notifications.dart';

// Configuration
import '../config/style.dart';

// All pages that can be displayed by the home screen
// Ordered in by the tab buttons from left to right
enum Page { HOME_PAGE, TREND_PAGE, CONFIG_PAGE, USER_PAGE }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Page _currentPage;

  // Reference to the Pi's that a specific user has access to
  final CollectionReference _userAccess =
      FirebaseFirestore.instance.collection('UserAccess');

  // Reference to the subscription to the users Pis
  StreamSubscription<DocumentSnapshot> _piSub;

  Map userPis; // Stores user authorized Pis

  List<String> piStrs = [];

  // Current system name
  String currentSystemName = null;

  // Main content showed in the middle of the screen
  StatefulWidget displayedPage;

  @override
  void initState() {
    super.initState();

    initUserPiSubscriptions();

    // Initialize Push Notifications
    PushNotificationsManager().init();
  }

  // Callback when the bottom tab buttons are pressed
  // Selects the correct page to show and then displays it
  void _selectedTab(int index) {
    setState(() {
      // TODO: depending on the selected state index, we display screens
      if (index == 0) {
        _currentPage = Page.HOME_PAGE;
      } else if (index == 1) {
        _currentPage = Page.TREND_PAGE;
      } else if (index == 2) {
        _currentPage = Page.CONFIG_PAGE;
      } else if (index == 3) {
        _currentPage = Page.USER_PAGE;
      } else {
        _currentPage = Page.HOME_PAGE;
      }
    });
    showSelectedPage(_currentPage);
  }

  // Select the correct page to show
  void showSelectedPage(Page page) {
    setState(() {
      // Force user to add system if none added
      if (currentSystemName == null) {
        displayedPage = AddSystemPage();
        return;
      }

      switch (page) {
        case Page.CONFIG_PAGE:
          displayedPage = ConfigPage(currentSystemName);
          break;
        case Page.HOME_PAGE:
          displayedPage = StatusPage(currentSystemName);
          break;
        case Page.TREND_PAGE:
          displayedPage = ChartPage(currentSystemName);
          break;
        case Page.USER_PAGE:
          displayedPage = UserPage();
          break;
        default:
          displayedPage = StatusPage(currentSystemName);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shows the page and the bottom bar on the screen
    return Scaffold(
      // Displays title and title bar
      appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("PiPonic"),
          ]),
          backgroundColor: lightBlue400),
      // Displays side bar with system options
      drawer: Drawer(
        child: ListView(children: <Widget>[
          Container(
            height: 70.0,
            child: DrawerHeader(
              child: Text('Select a system:', style: TextStyle(fontSize: 20.0)),
              decoration: BoxDecoration(
                color: lightBlue400,
              ),
            ),
          ),

          // Displays list of systems available
          ListView.builder(
              shrinkWrap: true,
              itemCount: piStrs.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return new ListTile(
                  title: Text(piStrs[index]),
                  onTap: () {
                    setState(() {
                      // Switch to selected system
                      currentSystemName = piStrs[index];

                      // Show the current page for new system
                      showSelectedPage(_currentPage);
                    });
                    // Then close the drawer (side tab)
                    Navigator.pop(context);
                  },
                );
              }),
        ]),
      ),
      // Displays main content of the page
      body: displayedPage,
      // Displays bottom icons
      bottomNavigationBar: CustomBottomAppBar(
        onTabSelected: _selectedTab,
        items: [
          CustomAppBarItem(
            icon: Icons.home,
            hasNotification: false,
          ),
          CustomAppBarItem(
            icon: Icons.trending_up,
            hasNotification: false,
          ),
          CustomAppBarItem(
            icon: Icons.settings,
            hasNotification: false,
          ),
          CustomAppBarItem(
            icon: Icons.account_circle,
            hasNotification: false,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    // End subscription to user's Pis
    _piSub.cancel();
  }

  // Initializes connections to Firestore database for user allowed Pis
  void initUserPiSubscriptions() {
    // subscribe to authorized user Pis
    User result = FirebaseAuth.instance.currentUser;

    _piSub = _userAccess.doc(result.uid).snapshots().listen((querySnapshot) {
      setState(() {
        // Save the user authorized Pis
        print("what: " + querySnapshot.data().toString());
        piStrs = (querySnapshot.data() != null)
            ? querySnapshot.data()['systems'].cast<String>()
            : null;

        // On initialization, show first name in list
        currentSystemName =
            (piStrs != null && piStrs.length != 0) ? piStrs[0] : null;

        // By default, show home page when starting up
        showSelectedPage(Page.HOME_PAGE);
      });
    });
  }
}
