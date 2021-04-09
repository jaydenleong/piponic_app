/*
 * File: bottom_bar.dart
 * 
 * Purpose: Custom bottom bar displayed in our app.
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

import '../config/style.dart';

// Items in the app bar will have two properties
// @icon: the icon display
// @hasNotification: whether or not there is a notification within the tab
class CustomAppBarItem {
  IconData icon;
  bool hasNotification;

  CustomAppBarItem({this.icon, this.hasNotification});
}

// App bar will have items and an index associated with the items
// @onTabSelected: call back function
// @items: list of app bar items
class CustomBottomAppBar extends StatefulWidget {
  final ValueChanged<int> onTabSelected;
  final List<CustomAppBarItem> items;

  CustomBottomAppBar({this.onTabSelected, this.items});

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

// Bottom app bar will set change the index depending on the state of icon
// Initially we are on the first icon
class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0;

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> items = List.generate(widget.items.length, (index) {
      return _buildTabIcon(
          index: index, item: widget.items[index], onPressed: _updateIndex);
    });

    // TODO: In the row, we have to change the spacing and layout of items
    return BottomAppBar(
      color: hanBlue200,
      child: Container(
        height: 60.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        ),
      ),
      // Only if we want the floating button to have a circular gap
      //shape: CircularNotchedRectangle(),
    );
  }

  Widget _buildTabIcon(
      {int index, CustomAppBarItem item, ValueChanged<int> onPressed}) {
    return Expanded(
      child: SizedBox(
        height: 60.0,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            // If the tab has a notification, it would have a stack with a the icon and the notification indicator above it.
            child: item.hasNotification
                ? Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        color: _selectedIndex == index
                            ? shrineBackgroundWhite
                            : shrineBackgroundWhite.withOpacity(.60),
                        size: 24.0,
                      ),
                      Positioned(
                          top: 10.0,
                          right: 35.0,
                          child: Icon(
                            Icons.brightness_1,
                            color: Color(0xFFff0000),
                            size: 10.0,
                          )),
                    ],
                  )
                : Icon(
                    item.icon,
                    color: _selectedIndex == index
                        ? shrineBackgroundWhite
                        : shrineBackgroundWhite.withOpacity(.60),
                    size: 24.0,
                  ),
          ),
        ),
      ),
    );
  }
}
