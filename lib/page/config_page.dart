/*
 * File: config_page.dart
 * 
 * Purpose: Page used to set up thresholds and control a aqua/hydroponic system
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:settings_ui/settings_ui.dart';

// Config
import '../config/style.dart';

// Utils
import '../utils/iot.dart';

// All screens that can be displayed by config page
enum ConfigScreen { ALL_SETTINGS, GENERAL, CALIBRATE_PH, PH, TEMP }

class ConfigPage extends StatefulWidget {
  final String rpiName;

  const ConfigPage(this.rpiName);

  @override
  _ConfigPage createState() => _ConfigPage();
}

class _ConfigPage extends State<ConfigPage> {
  String _displayPumpStatus = 'Not Available';

  // Reference to system configurations from the Config Firestore collection
  // Update collection to send commands to a Raspberry Pi
  final CollectionReference _firestoreConfig =
      FirebaseFirestore.instance.collection('Config');

  Map config; // Stores commands statuses sent to system in Firestore

  Color pumpButtonColor; // Color of pump button

  bool value = false;

  ConfigScreen currentScreen;

  // pH configuration values
  final double MIN_PH_VALUE = 4;
  final double MAX_PH_VALUE = 10;
  double _targetPHSliderValue = 7;
  double _minPHSliderValue = 4;
  double _maxPHSliderValue = 10;

  // pH calibration values
  double _calibratePHSolution1 = 4;
  double _calibratePHSolution2 = 7;

  // Temp configuration values, in degrees celcius
  final double MAX_TEMP_VALUE = 30;
  final double MIN_TEMP_VALUE = 10;
  double _maxTempSliderValue = 25;
  double _minTempSliderValue = 15;

  // Time configuarion for slider
  final double MAX_TIME_MINUTES = 180;
  final double MIN_TIME_MINUTES = 1;
  double _updateTimeIntervalMin = 30;

  @override
  void didUpdateWidget(ConfigPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    getFirestoreConfig();
  }

  @override
  void initState() {
    super.initState();

    getFirestoreConfig();

    currentScreen = ConfigScreen.ALL_SETTINGS;
  }

  @override
  Widget build(BuildContext context) {
    switch (currentScreen) {
      case ConfigScreen.ALL_SETTINGS:
        return allSettingsScreen();
      case ConfigScreen.PH:
        return pHScreen();
      case ConfigScreen.CALIBRATE_PH:
        return calibratePHScreen();
      case ConfigScreen.TEMP:
        return tempScreen();
      case ConfigScreen.GENERAL:
        return generalSettingsScreen();
      default:
        return allSettingsScreen();
    }
  }

  void setScreen(ConfigScreen screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Widget with menu for all system setttings
  Widget allSettingsScreen() {
    return Column(
      children: [
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
                      Text("System Settings", style: TextStyle(fontSize: 16.0)),
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
              SettingsSection(
                title: 'Settings',
                tiles: [
                  SettingsTile(
                    title: 'General',
                    leading: Icon(Icons.settings),
                    onPressed: (BuildContext context) {
                      setScreen(ConfigScreen.GENERAL);
                    },
                  ),
                  SettingsTile(
                    title: 'pH',
                    leading: Image.asset(
                      'assets/flask.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                    onPressed: (BuildContext context) {
                      setScreen(ConfigScreen.PH);
                    },
                  ),
                  SettingsTile(
                    title: 'Temperature',
                    leading: Image.asset(
                      'assets/temperature-thermometer.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                    onPressed: (BuildContext context) {
                      setScreen(ConfigScreen.TEMP);
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Calibration',
                tiles: [
                  SettingsTile(
                    title: 'pH',
                    leading: Image.asset(
                      'assets/flask.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                    onPressed: (BuildContext context) {
                      setScreen(ConfigScreen.CALIBRATE_PH);
                    },
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget generalSettingsScreen() {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButton(
            onPressed: () {
              setScreen(ConfigScreen.ALL_SETTINGS);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.settings, size: 48)),
          Container(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.rpiName, style: TextStyle(fontSize: 24.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("General Settings",
                            style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Divider(
        color: Colors.grey,
        height: 25,
        thickness: 2,
        indent: 20,
        endIndent: 20,
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Sensor measurement interval: " +
                        _updateTimeIntervalMin.floor().toStringAsFixed(0) +
                        " min",
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _updateTimeIntervalMin,
                  min: MIN_TIME_MINUTES,
                  max: MAX_TIME_MINUTES,
                  divisions: (MAX_TIME_MINUTES ~/ 10),
                  onChanged: (double value) {
                    setState(() {
                      _updateTimeIntervalMin = value;
                    });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanBlue200,
                      onPressed: () {
                        updateGeneralConfig();
                      },
                      child: Text('Save Settings'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanRed300,
                      onPressed: () {
                        getFirestoreConfig();
                      },
                      child: Text('Cancel'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ]);
  }

  // Screen with pH settings
  Widget pHScreen() {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButton(
            onPressed: () {
              setScreen(ConfigScreen.ALL_SETTINGS);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/flask.png',
              width: 36.0,
              height: 36.0,
            ),
          ),
          Container(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.rpiName, style: TextStyle(fontSize: 24.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("pH Settings", style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Divider(
        color: Colors.grey,
        height: 25,
        thickness: 2,
        indent: 20,
        endIndent: 20,
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Target pH Level: " +
                        _targetPHSliderValue.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _targetPHSliderValue,
                  min: MIN_PH_VALUE,
                  max: MAX_PH_VALUE,
                  divisions: ((MAX_PH_VALUE - MIN_PH_VALUE) * 10).toInt(),
                  onChanged: (double value) {
                    setState(() {
                      _targetPHSliderValue = value;
                    });
                  }),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Maximum healthy pH level: " +
                        _maxPHSliderValue.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _maxPHSliderValue,
                  min: MIN_PH_VALUE,
                  max: MAX_PH_VALUE,
                  divisions: ((MAX_PH_VALUE - MIN_PH_VALUE) * 10).toInt(),
                  onChanged: (double value) {
                    setState(() {
                      _maxPHSliderValue = value;
                    });
                  }),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Minimum healthy pH Level: " +
                        _minPHSliderValue.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _minPHSliderValue,
                  min: MIN_PH_VALUE,
                  max: MAX_PH_VALUE,
                  divisions: ((MAX_PH_VALUE - MIN_PH_VALUE) * 10).toInt(),
                  onChanged: (double value) {
                    setState(() {
                      _minPHSliderValue = value;
                    });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanBlue200,
                      onPressed: () {
                        updatePHConfig();
                      },
                      child: Text('Save Settings'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanRed300,
                      onPressed: () {
                        getFirestoreConfig();
                      },
                      child: Text('Cancel'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ]);
  }

  Widget calibratePHScreen() {
    return SingleChildScrollView(
        child: Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButton(
            onPressed: () {
              setScreen(ConfigScreen.ALL_SETTINGS);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/flask.png',
              width: 36.0,
              height: 36.0,
            ),
          ),
          Container(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.rpiName, style: TextStyle(fontSize: 24.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("pH Calibration",
                            style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Divider(
        color: Colors.grey,
        height: 25,
        thickness: 2,
        indent: 20,
        endIndent: 20,
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                        "To calibrate, gather two solutions with known pH. Use solutions as close to your operating range as possible. Then, adjust the slider to mark the pH of your two solutions below. ",
                        style: TextStyle(fontSize: 16.0)),
                  )),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Solution 1 pH: " +
                        _calibratePHSolution1.toStringAsFixed(1),
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _calibratePHSolution1,
                  min: 1,
                  max: 14,
                  divisions: 130,
                  onChanged: (double value) {
                    setState(() {
                      _calibratePHSolution1 = value;
                    });
                  }),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Solution 2 pH: " +
                        _calibratePHSolution2.toStringAsFixed(1),
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _calibratePHSolution2,
                  min: 1,
                  max: 14,
                  divisions: 130,
                  onChanged: (double value) {
                    setState(() {
                      _calibratePHSolution2 = value;
                    });
                  }),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                        "Now, place the pH probe in the first solution for 5 minutes and then press the button below.",
                        style: TextStyle(fontSize: 16.0)),
                  )),
              RaisedButton(
                color: hanBlue200,
                onPressed: () {
                  calibratePH(1, _calibratePHSolution1);
                },
                child: Text('Calibrate with solution 1'),
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                        "Clean off the pH probe. Then place the pH probe in the second solution for 5 minutes and then press the button below.",
                        style: TextStyle(fontSize: 16.0)),
                  )),
              RaisedButton(
                color: hanBlue200,
                onPressed: () {
                  calibratePH(2, _calibratePHSolution2);
                },
                child: Text('Calibrate with solution 2'),
              ),
            ],
          ),
        ),
      ),
    ]));
  }

  // Temperature settings screen
  Widget tempScreen() {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButton(
            onPressed: () {
              setScreen(ConfigScreen.ALL_SETTINGS);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/temperature-thermometer.png',
              width: 36.0,
              height: 36.0,
            ),
          ),
          Container(
            child: Container(
              //margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.rpiName, style: TextStyle(fontSize: 24.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Temperature Settings",
                            style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Divider(
        color: Colors.grey,
        height: 25,
        thickness: 2,
        indent: 20,
        endIndent: 20,
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Maximum healthy temperature: " +
                        _maxTempSliderValue.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _maxTempSliderValue,
                  min: MIN_TEMP_VALUE,
                  max: MAX_TEMP_VALUE,
                  divisions: ((MAX_TEMP_VALUE - MIN_TEMP_VALUE) * 10).round(),
                  onChanged: (double value) {
                    setState(() {
                      _maxTempSliderValue = value;
                    });
                  }),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Minimum healthy temperature: " +
                        _minTempSliderValue.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.left),
              ),
              Slider(
                  value: _minTempSliderValue,
                  min: MIN_TEMP_VALUE,
                  max: MAX_TEMP_VALUE,
                  divisions: ((MAX_TEMP_VALUE - MIN_TEMP_VALUE) * 10).round(),
                  onChanged: (double value) {
                    setState(() {
                      _minTempSliderValue = value;
                    });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanBlue200,
                      onPressed: () {
                        updateTempConfig();
                      },
                      child: Text('Save Settings'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: hanRed300,
                      onPressed: () {
                        getFirestoreConfig();
                      },
                      child: Text('Cancel'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ]);
  }

  // Updates PH Settings in Firestore
  void updatePHConfig() {
    if (widget.rpiName != null) {
      // Get current RPI config from Firestore.
      _firestoreConfig.doc(widget.rpiName).get().then((querySnapshot) {
        setState(() {
          // Save configuration state
          config = Map<String, dynamic>.from(querySnapshot.data());

          // Update pH related values
          config['target_ph'] = _targetPHSliderValue;
          config['min_ph'] = _minPHSliderValue;
          config['max_ph'] = _maxPHSliderValue;

          // Update document with new values
          _firestoreConfig.doc(widget.rpiName).update(config).then((_) {
            print("PH settings updated successfully!");
          });
        });
      });
    }
  }

  // Call the cloud function to calibrate the pH
  void calibratePH(int calibrationNum, double pH) {
    // Only allow calibrations 2 calibrations
    if (calibrationNum != 1 && calibrationNum != 2) {
      print("[ERROR][CONFIG_PAGE] Invalid pH calibration number");
      return;
    }

    // Send command to device to calibrate the pH
    sendCommandtoDevice(<String, dynamic>{
      'device_id': widget.rpiName,
      'ph': pH,
      'calibration_num': calibrationNum
    });
  }

  // Update temperature settings in Firestore
  void updateTempConfig() {
    if (widget.rpiName != null) {
      // Get current RPI config from Firestore.
      _firestoreConfig.doc(widget.rpiName).get().then((querySnapshot) {
        setState(() {
          // Save configuration state
          config = Map<String, dynamic>.from(querySnapshot.data());

          // Update pH related values
          config['min_temperature'] = _minTempSliderValue;
          config['max_temperature'] = _maxTempSliderValue;

          // Update document with new values
          _firestoreConfig.doc(widget.rpiName).update(config).then((_) {
            print("Temperature settings updated successfully!");
          });
        });
      });
    }
  }

  void updateGeneralConfig() {
    if (widget.rpiName != null) {
      // Get current RPI config from Firestore.
      _firestoreConfig.doc(widget.rpiName).get().then((querySnapshot) {
        setState(() {
          // Save configuration state
          config = Map<String, dynamic>.from(querySnapshot.data());

          // Update pH related values
          config['update_interval_minutes'] = _updateTimeIntervalMin.floor();

          // Update document with new values
          _firestoreConfig.doc(widget.rpiName).update(config).then((_) {
            print("General settings updated successfully!");
          });
        });
      });
    }
  }

  // Initializes connections to Firestore database for status and config updates
  void getFirestoreConfig() {
    // Get configuration status on initialisation
    if (widget.rpiName != null) {
      _firestoreConfig.doc(widget.rpiName).get().then((querySnapshot) {
        setState(() {
          // Save configuration state
          config = Map<String, dynamic>.from(querySnapshot.data());

          // Update settings pages with current configuration values
          config.forEach((key, value) {
            switch (key) {
              case 'peristaltic_pump_on':
                _displayPumpStatus = (config[key]) ? "Stop Pump" : "Start Pump";
                pumpButtonColor = (config[key]) ? hanRed300 : hanGreen300;
                break;
              case 'target_ph':
                _targetPHSliderValue = config[key].toDouble();
                break;
              case 'min_ph':
                _minPHSliderValue = config[key].toDouble();
                break;
              case 'max_ph':
                _maxPHSliderValue = config[key].toDouble();
                break;
              case 'max_temperature':
                _maxTempSliderValue = config[key].toDouble();
                break;
              case 'min_temperature':
                _minTempSliderValue = config[key].toDouble();
                break;
              case 'update_interval_minutes':
                _updateTimeIntervalMin = config[key].toDouble();
                break;
              default:
                break; // Do nothing
            }
          });
          // Update Pump button
          if (config.containsKey("peristaltic_pump_on")) {}
        });
      });
    }
  }
}
