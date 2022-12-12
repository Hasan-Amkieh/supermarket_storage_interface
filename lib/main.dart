import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:sqflite/sqflite.dart';

import 'others/app_themes.dart';

class Main {

  static const String versionForWindows = "1.0.0.0";

  static late Database db;

  static AppTheme appTheme = AppTheme();

  static List<String> tables = [
    "Employee",
    "Office",
  ];

  static List<String> ops = [
    "Insert",
    "Update",
    "Delete",
    "Read",
  ];

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Main.db = await openDatabase('my_db.db');

  // await Main.db.execute(
  //     'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');

  await Main.db.close();

  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Supermarket Storage Interface',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(title: 'Supermarket Storage Interface'),
    )
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => HomePageState();

}

class HomePageState extends State<HomePage> {

  int pageIndex = 0;
  int modOP = 0; // modOP 0 = Insert / 1 = Update / 2 = Delete / 3 = Read
  int entity = 0;


  late double width, height;
  String chosenTable = Main.tables[0];
  String op = Main.ops[0];

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    Widget page, subpage;

    if (pageIndex == 0) {

      if (modOP == 0) { // Insert

        subpage = Column(
          children: [

          ],
        );

      }
      else if (modOP == 1) { // Update

        subpage = Column(
          children: [

          ],
        );

      }
      else if (modOP == 2) { // Delete

        subpage = Column(
          children: [

          ],
        );

      } else { // Read
        subpage = Container();
      }

      page = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chosen Operation: ", style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: op,
                items: Main.ops.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value, style: TextStyle(color: Main.appTheme.titleTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    op = newValue!;
                    switch (op) {
                      case "Insert":
                        modOP = 0;
                        break;
                      case "Update":
                        modOP = 1;
                        break;
                      case "Delete":
                        modOP = 2;
                        break;
                      case "Read":
                        modOP = 3;
                        break;
                    }
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chosen Entity: ", style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: chosenTable,
                items: Main.tables.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value, style: TextStyle(color: Main.appTheme.titleTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    chosenTable = newValue!;
                    switch (chosenTable) {
                      case "Employee":
                        entity = 0;
                        break;
                      case "Office":
                        entity = 1;
                        break;
                    }
                  });
                },
              ),
            ],
          ),
          subpage,
        ],
      );

    }
    else if (pageIndex == 1) {

      page = Container();

    }
    else { // then it should be 2, which is stats

      page = Container();

    }

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Main.appTheme.navigationBarColor,
          labelTextStyle: MaterialStateProperty.all(TextStyle(color: Main.appTheme.navIconColor)),
        ),
        child: NavigationBar(
          backgroundColor: Main.appTheme.navigationBarColor,
          animationDuration: const Duration(seconds: 1),
          height: Platform.isWindows ? (height * 0.08) : (height * 0.08),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: pageIndex,
          onDestinationSelected: (int newIndex) {
            setState(() {
              pageIndex = newIndex;
            });
          },
          destinations: [
            NavigationDestination(icon: Icon(Icons.mode_edit_outline, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.mode_edit, color: Main.appTheme.navIconColor), label: 'Modify'),
            NavigationDestination(icon: Icon(Icons.search_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.search, color: Main.appTheme.navIconColor), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.query_stats_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.query_stats, color: Main.appTheme.navIconColor), label: 'Stats'),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          child: SingleChildScrollView(
              child: page,
          ),
        ),
      ),
    );
  }
}
