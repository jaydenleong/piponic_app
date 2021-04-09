/*
 * File: helper.dart
 * 
 * Purpose: Miscellaneous helper functions
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

// Capitalizes each word in a string.
String titleCase(String text) {
  if (text == null) throw ArgumentError("string: $text");

  if (text.isEmpty) return text;

  /// If you are careful you could use only this part of the code as shown in the second option.
  return text
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
