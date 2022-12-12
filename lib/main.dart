import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:sqflite/sqflite.dart';
import 'package:supermarket_storage_interface/attribute.dart';

import 'others/app_themes.dart';

class Main {

  static const String versionForWindows = "1.0.0.0";

  static late Database db;

  static AppTheme appTheme = AppTheme();

  static late Map<String, List<AttributeForm>> tables;

  static List<String> ops = [
    "Insert",
    "Update",
    "Delete",
    "Read",
  ];

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Main.tables = { // table into their attributes
    "Employee": [
      AttributeForm(name: "employeeID", type: "CHAR", size1: 10, isPK: true),
      AttributeForm(name: "firstName", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "lastName", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "jobTitle", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "email", type: "VARCHAR", size1: 25),
      AttributeForm(name: "managerID", type: "CHAR", size1: 10, tableFK: "Employee", nameFK: "employeeID"),
      AttributeForm(name: "phoneNumber", type: "CHAR", size1: 11, canBeNull: false),
      AttributeForm(name: "startDate", type: "DATE", canBeNull: false),
      AttributeForm(name: "employeeOffice", type: "CHAR", size1: 3, tableFK: "Office", nameFK: "officeNumber"),
    ],
    "Office": [
      AttributeForm(name: "officeNumber", type: "CHAR", size1: 3, isPK: true),
      AttributeForm(name: "officePhone", type: "CHAR", size1: 11),
      AttributeForm(name: "officeManager", type: "CHAR", size1: 10, tableFK: "Employee", nameFK: "employeeID"),
    ],
    "Department": [
      AttributeForm(name: "depID", type: "CHAR", size1: 5, isPK: true),
      AttributeForm(name: "depName", type: "VARCHAR", size1: 20, canBeNull: false),
    ],
    "Customer": [
      AttributeForm(name: "customerID", type: "CHAR", size1: 10, isPK: true),
      AttributeForm(name: "city", type: "VARCHAR", size1: 15),
      AttributeForm(name: "addressLine1", type: "VARCHAR", size1: 30),
      AttributeForm(name: "addressLine2", type: "VARCHAR", size1: 30),
      AttributeForm(name: "customerName", type: "VARCHAR", size1: 25, canBeNull: false),
      AttributeForm(name: "phoneNumber", type: "CHAR", size1: 11, canBeNull: false),
      AttributeForm(name: "state", type: "VARCHAR", size1: 15),
      AttributeForm(name: "postalCode", type: "INTEGER", canBeNull: false),
      AttributeForm(name: "employeeID", type: "CHAR", size1: 10, tableFK: "Employee", nameFK: "employeeID"),
    ],
    "Orders": [
      AttributeForm(name: "orderTime", type: "TIMESTAMP", canBeNull: false),
      AttributeForm(name: "orderNumber", type: "CHAR", size1: 20, isPK: true),
      AttributeForm(name: "paymentMethod", type: "VARCHAR", size1: 15),
      AttributeForm(name: "total", type: "NUMERIC", size1: 10, size2: 2, canBeNull: false), // length of 10 with 2 decimals
      AttributeForm(name: "customerID", type: "CHAR", size1: 10, tableFK: "Orders", nameFK: "customerID"),
    ],
    "OrderDetail": [
      AttributeForm(name: "orderNumber", type: "CHAR", size1: 20, tableFK: "Orders", nameFK: "orderNumber"),
      AttributeForm(name: "productCode", type: "CHAR", size1: 20, tableFK: "Products", nameFK: "productCode"),
      AttributeForm(name: "quantity", type: "SMALLINT", canBeNull: false, defaultValue: 1),
    ],
    "Products": [
      AttributeForm(name: "productCode", type: "CHAR", size1: 20, isPK: true),
      AttributeForm(name: "expireDate", type: "DATE", canBeNull: false, defaultValue: DateTime.now().add(const Duration(days: 30))),
      AttributeForm(name: "amountInStock", type: "INTEGER", canBeNull: false),
      AttributeForm(name: "productName", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "productDescription", type: "VARCHAR", size1: 35, canBeNull: false),
      AttributeForm(name: "productVendor", type: "VARCHAR", size1: 25),
      AttributeForm(name: "purchasePrice", type: "FLOAT", canBeNull: false),
      AttributeForm(name: "sellingPrice", type: "FLOAT", canBeNull: false),
      AttributeForm(name: "MSRP", type: "FLOAT"),
      AttributeForm(name: "productLine", type: "CHAR", size1: 10, tableFK: "ProductLine", nameFK: "productLine"),
    ],
    "ProductLine": [
      AttributeForm(name: "productLine", type: "CHAR", size1: 10, isPK: true),
      AttributeForm(name: "lineVendor", type: "VARCHAR", size1: 20),
      AttributeForm(name: "lineCategory", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "description", type: "VARCHAR", size1: 30),
    ],
  };

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
  String chosenTable = Main.tables.keys.first;
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
                  }); //
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
                items: Main.tables.keys.map<DropdownMenuItem<String>>((String value) {
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
