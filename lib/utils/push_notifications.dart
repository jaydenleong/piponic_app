/*
 * File: push_notifications.dart
 * 
 * Purpose: Configures the app to recieve notifications from 
 *          Firebase Cloud Messaging
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

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  final CollectionReference _userAccess =
      FirebaseFirestore.instance.collection('UserAccess');

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // Fetch Firebase User ID
      var currentUserId = FirebaseAuth.instance.currentUser.uid;

      if (currentUserId != null) {
        _userAccess.doc(currentUserId).get().then((querySnapshot) {
          // Fetch names of Raspberry Pis
          List<String> piStrs = (querySnapshot.data() != null)
              ? querySnapshot.data()['systems'].cast<String>()
              : [];

          // Subscribe to RPi notifications for each Raspberry pi the user
          // can monitor
          piStrs.forEach((pi) {
            _firebaseMessaging.subscribeToTopic(pi);
          });

          _initialized = true;
        });
      }
    }
  }
}
