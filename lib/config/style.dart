/*
 * File: styles.dart
 * 
 * Purpose: Defines common styles and colors used throught the app.
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

// ----------  COLORS  ------------
// WHITE
const Color white0 = Color(0xFFFFFFFF);
const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;

// BLUE
const Color hanBlue100 = Color(0xFFB1D2E6);
const Color hanBlue200 = Color(0xFF81B6D5);
const Color lightBlue50 = Color(0xFFE1F5FE);
const Color lightBlue100 = Color(0xFFB3E5FC);
const Color lightBlue300 = Color(0xFF4FC3F7);
const Color lightBlue400 = Color(0xFF29B6F6);
const Color lightBlue900 = Color(0xFF01579B);
const Color lightBlue600 = Color(0xFF0277BD);

// GREEN
const Color hanGreen100 = Color(0xFFD6E7C8);
const Color hanGreen300 = Color(0xFFA2C883);

const Color complementary100 = Color(0xFFFCCAB3);

// PINK
const Color shrinePink50 = Color(0xFFFEEAE6);
const Color shrinePink100 = Color(0xFFFEDBD0);
const Color shrinePink300 = Color(0xFFFBB8AC);
const Color shrinePink400 = Color(0xFFEAA4A4);

// BROWN
const Color shrineBrown900 = Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);

// RED
const Color shrineErrorRed = Color(0xFFC5032B);
const Color hanRed300 = Color(0xFFEA9999);

// SHRINE COLOR SCHEME
const ColorScheme shrineColorScheme = ColorScheme(
  primary: hanBlue200,
  primaryVariant: shrinePink100,
  secondary: hanGreen300, // This is used for the color of the button
  secondaryVariant: shrinePink100,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

// ---------- THEME SETTINGS ----------
const defaultLetterSpacing = 0.03;

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 0,
          letterSpacing: defaultLetterSpacing,
        ),
        button: base.button.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: shrineBrown900,
        bodyColor: shrineBrown900,
      );
}

ThemeData buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: shrineColorScheme,
    textTheme: _buildShrineTextTheme(base.textTheme),
  );
}
