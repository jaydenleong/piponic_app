/*
 * File: iot.dart
 * 
 * Purpose: Helper functions to communicate with Google Cloud IoT devices
 *  
 * Authors: Mason Duan, Jayden Leong
 * 
 * Date: March 26, 2021
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

import 'package:cloud_functions/cloud_functions.dart';

// Call the cloud function to calibrate the pH
// Ensure data contains the 'device_id' field!
Future<void> sendCommandtoDevice(var data) async {
  // Get the cloud function to calibrate pH
  HttpsCallable iotDeviceCommand =
      FirebaseFunctions.instance.httpsCallable('iotDeviceCommand');

  // Call the cloud function to calibrate pH
  await iotDeviceCommand.call(data);
}
