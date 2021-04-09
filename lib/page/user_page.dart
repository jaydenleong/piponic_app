/*
 * File: user_page.dart
 *
 * Purpose: Defines page that users can use to handle user function.
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pages
import './signin_page.dart';

// Style
import '../config/style.dart';

// All pages within the user page
enum UserScreen { ALL_SETTINGS, ADD_SYSTEM }

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _piIdController = TextEditingController();

  bool isLoading = false;

  // Firestore collection with Pis a user can access
  final CollectionReference _userAccessCollection =
      FirebaseFirestore.instance.collection('UserAccess');

  // Firestore collection with system sensor status
  final CollectionReference _statusCollection =
      FirebaseFirestore.instance.collection("Status");

  FirebaseAuth result = null;

  // Keeps track of the current page
  UserScreen currentPage = UserScreen.ALL_SETTINGS;

  // Current user's email
  String userEmail = "";

  @override
  void initState() {
    super.initState();

    // Show all settings by default
    setPage(UserScreen.ALL_SETTINGS);

    // Get current user
    result = FirebaseAuth.instance;

    // Get user's email to display
    updateUserEmail();
  }

  // Switches pages
  void setPage(UserScreen page) {
    setState(() {
      currentPage = page;
    });
  }

  // Fetches current user's email from Firestore
  void updateUserEmail() {
    _userAccessCollection
        .doc(result.currentUser.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        userEmail = querySnapshot.data()['email'];
      });
    });
  }

  Widget build(BuildContext context) {
    switch (currentPage) {
      case UserScreen.ALL_SETTINGS:
        return allUserSettingsPage();
      case UserScreen.ADD_SYSTEM:
        return addSystemPage();
      default:
        return allUserSettingsPage();
    }
  }

  // Widget with text field for users to add a new system
  Widget addSystemPage() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                BackButton(
                  onPressed: () {
                    setPage(UserScreen.ALL_SETTINGS);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Add System",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          fontFamily: 'Roboto')),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: _piIdController,
                decoration: InputDecoration(
                  labelText: "Enter System Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Aquaponics ID';
                  } else if (!value.contains('Pi')) {
                    return 'Please enter a valid Aquaponics ID!';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          addAquaponicsSystem();
                        }
                      },
                      child: Text('Submit'),
                    ),
            )
          ],
        ),
      ),
    );
  }

  // All settings for a user account
  Widget allUserSettingsPage() {
    return Column(
      children: [
        Container(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(userEmail, style: TextStyle(fontSize: 24.0)),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Account Settings",
                          style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 25,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),
        Expanded(
          child: SettingsList(
            backgroundColor: shrineSurfaceWhite,
            sections: [
              SettingsSection(title: 'Systems', tiles: [
                SettingsTile(
                  title: 'Add a system to monitor',
                  leading: Icon(Icons.add),
                  onPressed: (BuildContext context) {
                    setPage(UserScreen.ADD_SYSTEM);
                  },
                ),
              ]),
              SettingsSection(title: 'Account', tiles: [
                SettingsTile(
                  title: 'Logout',
                  leading: Icon(Icons.logout),
                  onPressed: (BuildContext context) {
                    _debugSignOUt();
                  },
                ),
                SettingsTile(
                  title: 'Delete Account',
                  leading: Icon(Icons.delete),
                  onPressed: (BuildContext context) {
                    _debugDeleteUser();
                  },
                ),
              ])
            ],
          ),
        )
      ],
    );
  }

  void _debugDeleteUser() {
    if (result != null) {
      result.currentUser.delete();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninPage()),
    );
  }

  void _debugSignOUt() async {
    await result.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninPage()),
    );
  }

  // Add another aqua/hydroponic system so the user can access it.
  void addAquaponicsSystem() {
    User result = FirebaseAuth.instance.currentUser;

    _statusCollection.doc(_piIdController.text).get().then((querySnapshot) {
      // Check if the Raspberry Pi actually exists in our system
      if (querySnapshot.exists) {
        //  Fetch current system the user has access to
        Map userAccessData;
        List<String> piStrs = [];
        _userAccessCollection.doc(result.uid).get().then((querySnapshot) {
          userAccessData = querySnapshot.data();
          piStrs = querySnapshot.data()['systems'].cast<String>();

          // Add new system so user can access it
          if (!piStrs.contains(_piIdController.text)) {
            piStrs.add(_piIdController.text);
            userAccessData['systems'] = piStrs;

            // Update Firestore
            _userAccessCollection.doc(result.uid).update(userAccessData);
          } else {
            // No updates as already have access to Pi
            print("[WARN][ADD_SYSTEM_PAGE] Already have access to the Pi");
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        print("[WARN][ADD_SYSTEM_PAGE] Not a valid Pi name!");
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
