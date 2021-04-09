/*
 * File: status_page.dart
 * 
 * Purpose: Page used to show sensor readings from a single aqua/hydroponic system
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../config/style.dart';
import '../utils/helper.dart';

class StatusPage extends StatefulWidget {
  final String rpiName;

  const StatusPage(this.rpiName);

  @override
  _StatusPage createState() => _StatusPage();
}

class _StatusPage extends State<StatusPage> {
  // Reference to system sensor readings in the Status Firestore collection
  final CollectionReference _firestoreStatus =
      FirebaseFirestore.instance.collection('Status');

  // Error status collection for systems in Firestore
  final CollectionReference _firestoreError =
      FirebaseFirestore.instance.collection('Error');

  // Reference to the subscription to real time status updates
  StreamSubscription<DocumentSnapshot> _statusSub;
  StreamSubscription<DocumentSnapshot> _errorSub;

  Map status; // Stores system sensor measurements from Firestore
  Map errorStatus; // Error data from systems

  List<String> statusStrs = []; // List of formatted status values to display
  List<String> errorStrs = []; // List of formatted errors to display

  String lastUpdateTime =
      ""; // String showing last time sensor measurements read

  // By default, show healthy status
  Color statusColor = hanGreen300;
  String aquaponicStatus = "Healthy";

  @override
  void didUpdateWidget(StatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cancel previous subscriptions to other system's data
    if (_statusSub != null) {
      _statusSub.cancel();
    }

    initFirestoreSubscriptions();
  }

  @override
  void initState() {
    super.initState();

    initFirestoreSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      // This is the aquaponics summary container
      Container(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(widget.rpiName, style: TextStyle(fontSize: 28.0)),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Status: ", style: TextStyle(fontSize: 16.0)),
                    Text(aquaponicStatus,
                        style:
                            new TextStyle(color: statusColor, fontSize: 16.0)),
                  ],
                ),
              ),
              Text("Last Updated: " + lastUpdateTime,
                  style: new TextStyle(fontSize: 16.0))
            ],
          ),
        ),
      ),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: errorStrs.length,
          itemBuilder: (BuildContext ctxt, int index) {
            Widget errorMsgWidget = new Container(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\u2022 " + errorStrs[index],
                          style: TextStyle(color: hanRed300, fontSize: 20.0),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            if (index == 0) {
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.,
                      children: [
                        Text(
                          "Warnings ",
                          style: TextStyle(fontSize: 24.0),
                          textAlign: TextAlign.left,
                        ),
                        Icon(Icons.warning, size: 24.0),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 25,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  errorMsgWidget
                ],
              );
            } else {
              return errorMsgWidget;
            }
          }),
      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.,
          children: [
            Text(
              "Status ",
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.left,
            ),
            Icon(Icons.settings_remote, size: 24.0),
          ],
        ),
      ),
      Divider(
        color: Colors.grey,
        height: 25,
        thickness: 2,
        indent: 20,
        endIndent: 20,
      ),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: statusStrs.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Container(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          statusStrs[index].split(": ")[0] + ":",
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          statusStrs[index].split(": ")[1],
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 25,
                      thickness: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
    ]));
  }

  @override
  void dispose() {
    super.dispose();

    // End subscription to data updates
    if (_statusSub != null) {
      _statusSub.cancel();
    }
    if (_errorSub != null) {
      _errorSub.cancel();
    }
  }

  // Formats sensors status updates into strings that can be displayed
  // Save output into a String list called statusStrs
  void formatStatus(Map status) {
    setState(() {
      // Clear previous status data
      if (statusStrs != null) {
        statusStrs.clear();
      }

      // Save each status field
      status.forEach((key, value) {
        switch (key) {
          case 'battery_voltage':
            statusStrs.add(
                "Battery Voltage: " + status[key].toStringAsFixed(2) + "V");
            break;
          case 'internal_leak':
            statusStrs.add("Internal Leak Sensor: " +
                status[key].abs().toStringAsFixed(2) +
                "V");
            break;
          case 'leak':
            statusStrs.add("External Leak Sensor: " +
                status[key].abs().toStringAsFixed(2) +
                "V");
            break;
          case 'pH':
            statusStrs.add("pH: " + status[key].toStringAsFixed(2));
            break;
          case 'temperature':
            statusStrs
                .add("Temperature: " + status[key].toStringAsFixed(2) + "°C");
            break;
          case 'timestamp':
            // Save formatted update time
            lastUpdateTime =
                DateFormat('h:mm a, MMM d, yyyy').format(status[key].toDate());
            break;
          case 'water_level':
            statusStrs.add("Water level: " + status[key].toString());
            break;
          default:
            // Try to format data even though it is not recognized
            String formattedKey =
                titleCase(key.replaceAll(new RegExp(r'_'), '_'));
            statusStrs.add(formattedKey + ": " + status[key].toString());
        }
      });

      // Sort strings alphabetically
      statusStrs.sort();
    });
  }

  // If there are any errors, format them for display
  void formatErrorStatus(errorStatus) {
    setState(() {
      // Clear previous status data
      if (errorStrs != null) {
        errorStrs.clear();
      }

      // Default system is healthy unless error
      bool isSystemHealthy = true;

      // Iterate through error data and display issues
      errorStatus.forEach((key, value) {
        // If any errors, mark system as unhealthy
        if (value) {
          isSystemHealthy = false;
        }

        // If any values are unhealthy,
        if (value) {
          switch (key) {
            case 'BATTERY_LOW':
              errorStrs.add("Battery voltage is low.");
              break;
            case 'INTERNAL_LEAK_DETECTED':
              errorStrs.add("Internal leak detected.");
              break;
            case 'LEAK_DETECTED':
              errorStrs.add("Leak detected.");
              break;
            case 'PH_HIGH':
              errorStrs.add("pH is too high.");
              break;
            case 'PH_LOW':
              errorStrs.add("pH is too low.");
              break;
            case 'TEMP_HIGH':
              // Save formatted update time
              errorStrs.add("Water temperature is too high.");
              break;
            case 'TEMP_LOW':
              // Save formatted update time
              errorStrs.add("Water temperature is too low.");
              break;
            case 'WATER_LEVEL_LOW':
              errorStrs.add("Water level is too low.");
              break;
            default:
              break;
          }
        }
      });

      // Update overall system status
      aquaponicStatus = (isSystemHealthy) ? "Healthy" : "Unhealthy";
      statusColor = (isSystemHealthy) ? hanGreen300 : hanRed300;
    });
  }

  // Initializes connections to Firestore database for status and config updates
  void initFirestoreSubscriptions() {
    if (widget.rpiName != null) {
      // Subscribe to sensor status updates
      _statusSub = _firestoreStatus
          .doc(widget.rpiName)
          .snapshots()
          .listen((querySnapshot) {
        // Format sensor measurements so they can be displayed on screen
        status = Map<String, dynamic>.from(querySnapshot.data());
        formatStatus(status);
      });

      // Subscribe to system error updates
      _errorSub = _firestoreError
          .doc(widget.rpiName)
          .snapshots()
          .listen((querySnapshot) {
        // Format error data for display
        errorStatus = Map<String, dynamic>.from(querySnapshot.data());
        formatErrorStatus(errorStatus);
      });
    }
  }
}
