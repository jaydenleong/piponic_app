/*
 * File: chart_page.dart
 *
 * Purpose: Page used to look at past historical data of a sensor in a system
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

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';

class ChartPage extends StatefulWidget {
  final String rpiName;

  const ChartPage(this.rpiName);

  @override
  _ChartPage createState() => _ChartPage();
}

class _ChartPage extends State<ChartPage> {
  // Reference to system configurations from the Config Firestore collection
  // Gets the history of recorded data of sensor
  final CollectionReference _firestoreHistory =
      FirebaseFirestore.instance.collection('History');

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  DateTime startDate;
  DateTime endDate;

  String chartId;

  String _setStartDate;
  String _setEndDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1930),
      lastDate: DateTime(2022),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              primaryColorDark: Colors.blue,
              accentColor: Colors.blue,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        _startDateController.text = DateFormat.yMd().format(startDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1930),
      lastDate: DateTime(2022),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              primaryColorDark: Colors.blue,
              accentColor: Colors.blue,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        _endDateController.text = DateFormat.yMd().format(endDate);
      });
    }
  }

  List<charts.Series<LinearMeasurements, DateTime>> _generateData(fbData) {
    List<charts.Series<LinearMeasurements, DateTime>> seriesLineData = [];
    if (chartId == "Battery Voltage") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.batteryVoltage,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    } else if (chartId == "Internal Leak") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.internalLeak,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    } else if (chartId == "Temperature") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.temperatureVal,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    } else if (chartId == "Leak") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.leakVal,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    } else if (chartId == "pH") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.phVal,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    } else if (chartId == "Water Level") {
      seriesLineData.add(charts.Series(
          domainFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.timestampVal,
          measureFn: (LinearMeasurements linearMeasurements, _) =>
              linearMeasurements.waterLevelVal,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          id: chartId,
          data: fbData));
    }
    print(seriesLineData.length);
    return seriesLineData;
  }

  @override
  void didUpdateWidget(ChartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      chartId = "Temperature";
      startDate = DateTime.now().subtract(new Duration(days: 1));
      DateTime.now();
      endDate = DateTime.now();
      _endDateController.text = DateFormat.yMd().format(endDate);
      _startDateController.text = DateFormat.yMd().format(startDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
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
                            Text("Historic Data",
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
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<String>(
                              focusColor: Colors.white,
                              value: chartId,
                              //elevation: 5,
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              items: <String>[
                                'Battery Voltage',
                                'Internal Leak',
                                'Leak',
                                'pH',
                                'Temperature',
                                'Water Level',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Please choose a Measurement",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  chartId = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10.0,
              ),
              Expanded(child: _buildBody(context)),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date range:", style: TextStyle(fontSize: 15.0)),
                  InkWell(
                    onTap: () {
                      _selectStartDate(context);
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _startDateController,
                        onSaved: (String val) {
                          _setStartDate = val;
                        },
                        decoration: InputDecoration(
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            // labelText: 'Time',
                            contentPadding: EdgeInsets.only(top: 0.0)),
                      ),
                    ),
                  ),
                  Text("to", style: TextStyle(fontSize: 15.0)),
                  InkWell(
                    onTap: () {
                      _selectEndDate(context);
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _endDateController,
                        onSaved: (String val) {
                          _setEndDate = val;
                        },
                        decoration: InputDecoration(
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            // labelText: 'Time',
                            contentPadding: EdgeInsets.only(top: 0.0)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreHistory
          .doc(widget.rpiName)
          .collection("History")
          .orderBy("timestamp", descending: true)
          .where('timestamp',
              isGreaterThan: Timestamp.fromDate(startDate),
              isLessThan: Timestamp.fromDate(endDate))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          List<LinearMeasurements> linearData = snapshot.data.docs
              .map((e) => LinearMeasurements.fromMap(e.data()))
              .toList();

          // TODO: Sort this list based on the object OR We have to insert them in an order
          return _buildChart(context, linearData);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<LinearMeasurements> testData) {
    //_generateData(testData);
    return charts.TimeSeriesChart(
      _generateData(testData),
      animate: false,
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      //domainAxis: new charts.EndPointsTimeAxisSpec(),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(zeroBound: false)),
      behaviors: [
        new charts.ChartTitle('Time',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
        new charts.ChartTitle(chartId,
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Simple Linear Data Type
class LinearMeasurements {
  final double batteryVoltage;
  final double internalLeak;
  final double leakVal;
  final double phVal;
  final double temperatureVal;
  final DateTime timestampVal;
  final double waterLevelVal;

  LinearMeasurements.fromMap(Map<String, dynamic> map)
      : assert(map["timestamp"] != null),
        batteryVoltage = (map["battery_voltage"] != null)
            ? map["battery_voltage"].toDouble()
            : null,
        internalLeak = (map["internal_leak"] != null)
            ? map["internal_leak"].toDouble()
            : null,
        leakVal = (map["leak"] != null) ? map["leak"].toDouble() : null,
        phVal = (map["pH"] != null) ? map["pH"].toDouble() : null,
        temperatureVal =
            (map["temperature"] != null) ? map["temperature"].toDouble() : null,
        timestampVal = new DateTime.fromMicrosecondsSinceEpoch(map["timestamp"]
            .microsecondsSinceEpoch), //map["timestamp"].millisecondsSinceEpoch,
        waterLevelVal =
            (map["water_level"] != null) ? map["water_level"].toDouble() : null;

  LinearMeasurements(this.batteryVoltage, this.internalLeak, this.leakVal,
      this.phVal, this.temperatureVal, this.timestampVal, this.waterLevelVal);
}
