/*
 * File: add_system_page.dart
 *
 * Purpose: Defines page that users can use to add aquaponics system.
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSystemPage extends StatefulWidget {
  @override
  _AddSystemPageState createState() => _AddSystemPageState();
}

class _AddSystemPageState extends State<AddSystemPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _piIdController = TextEditingController();

  bool isLoading = false;

  // Firestore collection with Pis a user can access
  final CollectionReference _userAccessCollection =
      FirebaseFirestore.instance.collection('UserAccess');

  // Firestore collection with system sensor status
  final CollectionReference _statusCollection =
      FirebaseFirestore.instance.collection("Status");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Add System to Monitor",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          fontFamily: 'Roboto')),
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
        ),
      ),
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
          print(userAccessData);
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
