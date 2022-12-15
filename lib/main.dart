import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
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
  ];

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Main.tables = { // table into their attributes
    "Employee": [
      AttributeForm(name: "employeeID", type: "INTEGER", isPK: true),
      AttributeForm(name: "firstName", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "lastName", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "jobTitle", type: "VARCHAR", size1: 20, canBeNull: false),
      AttributeForm(name: "email", type: "VARCHAR", size1: 25),
      AttributeForm(name: "managerID", type: "INTEGER", tableFK: "Employee", nameFK: "employeeID"),
      AttributeForm(name: "phoneNumber", type: "CHAR", size1: 11, canBeNull: false),
      AttributeForm(name: "startDate", type: "DATE", canBeNull: false, defaultValue: "SELECT date()", hintText: "E.g 2019-12-21"),
      AttributeForm(name: "employeeOffice", type: "NUMERIC", size1: 3, tableFK: "Office", nameFK: "officeNumber"),
    ],
    "Office": [
      AttributeForm(name: "officeNumber", type: "NUMERIC", size1: 3, isPK: true),
      AttributeForm(name: "officePhone", type: "CHAR", size1: 11),
      AttributeForm(name: "officeManagerID", type: "INTEGER", tableFK: "Employee", nameFK: "employeeID"),
    ],
    "Department": [
      AttributeForm(name: "depID", type: "SMALLINT", isPK: true),
      AttributeForm(name: "depName", type: "VARCHAR", size1: 20, canBeNull: false),
    ],
    "Customer": [
      AttributeForm(name: "customerID", type: "INTEGER", isPK: true),
      AttributeForm(name: "city", type: "VARCHAR", size1: 15),
      AttributeForm(name: "addressLine1", type: "VARCHAR", size1: 30),
      AttributeForm(name: "addressLine2", type: "VARCHAR", size1: 30),
      AttributeForm(name: "customerName", type: "VARCHAR", size1: 25, canBeNull: false),
      AttributeForm(name: "phoneNumber", type: "CHAR", size1: 11, canBeNull: false),
      AttributeForm(name: "state", type: "VARCHAR", size1: 15),
      AttributeForm(name: "postalCode", type: "INTEGER", canBeNull: false),
      AttributeForm(name: "employeeID", type: "INTEGER", tableFK: "Employee", nameFK: "employeeID"),
    ],
    "Orders": [
      AttributeForm(name: "orderTime", type: "TIMESTAMP", canBeNull: false, defaultValue: "SELECT datetime()", hintText: "E.g 2019-12-21 09:30:55"),
      AttributeForm(name: "orderNumber", type: "INTEGER", isPK: true),
      AttributeForm(name: "paymentMethod", type: "VARCHAR", size1: 15),
      AttributeForm(name: "total", type: "NUMERIC", size1: 10, size2: 2, canBeNull: false), // length of 10 with 2 decimals
      AttributeForm(name: "customerID", type: "INTEGER", tableFK: "Customer", nameFK: "customerID"),
    ],
    "OrderDetail": [
      AttributeForm(name: "orderNumber", type: "INTEGER", tableFK: "Orders", nameFK: "orderNumber"),
      AttributeForm(name: "productCode", type: "INTEGER", tableFK: "Products", nameFK: "productCode"),
      AttributeForm(name: "quantity", type: "SMALLINT", canBeNull: false, defaultValue: 1),
    ],
    "Products": [
      AttributeForm(name: "productCode", type: "INTEGER", isPK: true),
      AttributeForm(name: "expireDate", type: "DATE", canBeNull: false, defaultValue: "SELECT date('now', '+1 month')", hintText: "E.g 2019-12-21"),
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
    "works_for": [
      AttributeForm(name: "depID", type: "SMALLINT", tableFK: "Department", nameFK: "depID"),
      AttributeForm(name: "employeeID", type: "INTEGER", tableFK: "Employee", nameFK: "employeeID"),
      AttributeForm(name: "startHour", type: "CHAR", size1: 2, canBeNull: false),
      AttributeForm(name: "endHour", type: "CHAR", size1: 2, canBeNull: false),
    ],
  };

  Main.db = await openDatabase('my_db1.db');
  bool isErr = true;

  try {
    await Main.db.execute("CREATE TABLE Employee (id INTEGER PRIMARY KEY)");
    await Main.db.execute("DROP TABLE Employee");
    isErr = false;
  } catch (err, stacktrace) {
    if (!err.toString().contains("already exists")) {
      print("ERROR: $err\n$stacktrace");
    }
  }

  if (!isErr) {
    Main.tables.forEach((key, value) async {

      String valsStr = "(";
      value.forEach((element) {
        if (valsStr[valsStr.length-1] != "(") {
          valsStr += ', ';
        }
        valsStr += "${element.name} ";
        switch(element.type) {
          case "NUMERIC":
            valsStr += "NUMERIC(${element.size1},${element.size2})";
            break;
          case "CHAR":
            valsStr += "CHAR(${element.size1})";
            break;
          case "VARCHAR":
            valsStr += "VARCHAR(${element.size1})";
            break;
          default:
            valsStr += element.type;
        }
        valsStr += " ";
        if (element.isPK) {
          valsStr += "PRIMARY KEY";
        }
        valsStr += " ";
        if (!element.canBeNull) {
          valsStr += "NOT NULL";
        }
        valsStr += " ";
        if (element.tableFK.isNotEmpty) {
          valsStr += (" REFERENCES ${element.tableFK}(${element.nameFK})");
        }
        valsStr += " ";
      });

      // print("Executing ${'CREATE TABLE $key $valsStr)'}");
      await Main.db.execute('CREATE TABLE $key $valsStr)');
      valsStr = "";
      // fks.clear();
    });
  }

  runApp(
      OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Supermarket Storage Interface',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HomePage(title: 'Supermarket Storage Interface'),
    ),
      )
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => HomePageState();

}

class HomePageState extends State<HomePage>  {

  int pageIndex = 0;
  int modOP = 0; // modOP 0 = Insert / 1 = Update / 2 = Delete // NOTE: Update is used for reading and updating
  int entity = 0;

  AttributeForm chosenAttr = Main.tables["Employee"]![0];

  TextEditingController searchController = TextEditingController();

  late double width, height;
  String chosenTable = Main.tables.keys.first;
  String op = Main.ops[0];

  List<TextEditingController> controllers = [];

  Map<String, int> updateID = {};
  List<dynamic> attrsToDisplay = [];

  List<Map> searchListOriginal = [];

  @override
  Widget build(BuildContext context) {

    controllers.clear();

    Widget btn = Container();

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    Widget page = Container(), subpage = Container();

    if (pageIndex == 0) {

      if (modOP == 0) { // Insert

        List<Widget> list = [];

        Main.tables[chosenTable]?.forEach((element) {

          int maxLength = 100;
          if (element.type.contains("CHAR") || element.type.contains("NUMERIC")) {
            maxLength = element.size1;
          } else if (element.type.contains("INTEGER")) {
            maxLength = 10;
          } else if (element.type.contains("SMALLINT")) {
            maxLength = 6;
          } else if (element.type.contains("TIMESTAMP")) {
            maxLength = 19;
          } else if (element.type.contains("DATE")) {
            maxLength = 10;
          }

          controllers.add(TextEditingController());

          list.add(SizedBox(height: height * 0.01));
          list.add(
              TextField(
                controller: controllers[controllers.length - 1],
                style: TextStyle(color: Colors.white),
                maxLength: maxLength,
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  labelText: element.name,
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: element.hintText.isNotEmpty ? element.hintText : 'Enter ${element.name}',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              )
          );

        });

        btn = TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Add"),
          onPressed: () async {

            // print((await Main.db.rawQuery("SELECT * FROM Employee")).toString());
            // return;

            List<dynamic> attrs = [];
            String vars = "";
            for (int i = 0 ; i < Main.tables[chosenTable]!.length ; i++) {
              // print("Text: ${controllers[i].text}");
              if (controllers[i].text.isEmpty) {
                if (Main.tables[chosenTable]![i].defaultValue != null) {
                  if (Main.tables[chosenTable]![i].defaultValue.toString().contains("date")) {
                    String str = (await Main.db.rawQuery("${Main.tables[chosenTable]![i].defaultValue}"))[0].values.toList()[0].toString();
                    print("Date of $str");
                    attrs.add(str);
                  } else {
                    attrs.add(Main.tables[chosenTable]![i].defaultValue);
                  }
                  vars += "${Main.tables[chosenTable]![i].name}, ";
                }
                continue;
              }
              if (Main.tables[chosenTable]![i].type.contains("INT") || Main.tables[chosenTable]![i].type.contains("NUMERIC")) {
                attrs.add(int.parse(controllers[i].text));
              } else {
                attrs.add(controllers[i].text);
              }
              vars += "${Main.tables[chosenTable]![i].name}, ";
            }
            // print("attrs: $attrs");
            vars = vars.substring(0, vars.length - 2);
            String marks = "";
            for (int i = 0 ; i < attrs.length ; i++) {
              marks += "?, ";
            }
            marks = marks.substring(0, marks.length - 2);
            print("PERFORMING: INSERT INTO Employee($vars) VALUES ($attrs)");

            try {
              await Main.db.rawInsert("INSERT INTO $chosenTable($vars)"
                  " VALUES ($marks)", attrs);
              showToast(
                "Added successfully",
                duration: const Duration(milliseconds: 1500),
                position: ToastPosition.bottom,
                backgroundColor: Colors.blue.withOpacity(0.8),
                radius: 100.0,
                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
              );
            } catch (err, stacktrace) {
              print("ERROR: $err\n$stacktrace");
              showToast(
                "ERROR: " + err.toString().substring(err.toString().indexOf("DatabaseException") + 18, err.toString().indexOf("(", err.toString().indexOf("DatabaseException") + 20)),
                duration: const Duration(milliseconds: 5000),
                position: ToastPosition.bottom,
                backgroundColor: Colors.red.withOpacity(0.8),
                radius: 100.0,
                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
              );
            }

            // print("deleted employees count: ${(await Main.db.rawDelete("DELETE FROM Employee WHERE employeeID = ?", [1])).toString()}");
            // print("employees count: ${(await Main.db.rawQuery("SELECT employeeID FROM Employee")).toString()}");
            // await Main.db.rawInsert("INSERT INTO Employee(firstName, lastName, phoneNumber, email, jobTitle, startDate)"
            //     " VALUES (?, ?, ?, ?, ?, ?)", ["Hasan", "Amkieh", "+8955456970", "hassan1551@outlook.com", "Programmer",
            //   DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString()]);

            // await Main.db.execute("DROP TABLE Employee");
            // await Main.db.execute("DROP TABLE Office");
            // await Main.db.execute("DROP TABLE Department");
            // await Main.db.execute("DROP TABLE Customer");
            // await Main.db.execute("DROP TABLE Orders");
            // await Main.db.execute("DROP TABLE OrderDetail");
            // await Main.db.execute("DROP TABLE Products");
            // await Main.db.execute("DROP TABLE ProductLine");
            // await Main.db.execute("DROP TABLE works_for");
          },
        );

        // list
        subpage = ListView(
          children: list,
        );

      }
      else if (modOP == 1) { // Update

        List<Widget> list = [];

        if (attrsToDisplay.isEmpty) { // Getting the data

          btn = TextButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text("Get Info"),
            onPressed: () async {

              int count = 0;
              for (int i = 0 ; i < Main.tables[chosenTable]!.length ; i++) {
                var element = Main.tables[chosenTable]![i];
                if (!element.isPK && element.tableFK.isEmpty) {
                  continue;
                }
                if (controllers[count].text.isNotEmpty) {
                  updateID.addEntries([MapEntry(element.name, int.parse(controllers[count].text))]);
                }
                count++;
              }

              String rules = "";
              List<dynamic> vals = updateID.values.toList();
              updateID.forEach((key, value) {
                rules += "$key = ? AND ";
              });
              rules = rules.substring(0, rules.length - 4);
              attrsToDisplay =
              await Main.db.rawQuery("SELECT * FROM $chosenTable WHERE $rules", vals);
              setState(() {
                if (attrsToDisplay.isNotEmpty) {
                  print("received: $attrsToDisplay");
                } else {
                  showToast(
                    "No results found",
                    duration: const Duration(milliseconds: 1500),
                    position: ToastPosition.bottom,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    radius: 100.0,
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                  );
                }
              });

            },
          );

          for (int j = 0 ; j < Main.tables[chosenTable]!.length ; j++) {
            var element = Main.tables[chosenTable]![j];
            if (!element.isPK && element.tableFK.isEmpty) {
              // print("${element.name} is dismissed");
              continue;
            }

            int maxLength = 100;
            if (element.type.contains("CHAR") || element.type.contains("NUMERIC")) {
              maxLength = element.size1;
            } else if (element.type.contains("INTEGER")) {
              maxLength = 10;
            } else if (element.type.contains("SMALLINT")) {
              maxLength = 6;
            } else if (element.type.contains("TIMESTAMP")) {
              maxLength = 19;
            } else if (element.type.contains("DATE")) {
              maxLength = 10;
            }

            controllers.add(TextEditingController());

            list.add(SizedBox(height: height * 0.01));
            list.add(
                TextField(
                  controller: controllers[controllers.length - 1],
                  style: TextStyle(color: Colors.white),
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    counterStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    labelText: element.name,
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: element.hintText.isNotEmpty ? element.hintText : 'Enter ${element.name}',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                )
            );

          }

        } else { // update data:

          btn = TextButton.icon(
            icon: const Icon(Icons.upload_rounded),
            label: const Text("Update"),
            onPressed: () async {

              List<dynamic> attrs = [];
              String vars = "";
              for (int i = 0 ; i < Main.tables[chosenTable]!.length ; i++) {
                // print("Text: ${controllers[i].text}");
                if (controllers[i].text.isEmpty) {
                  if (Main.tables[chosenTable]![i].defaultValue != null) {
                    // attrs.add(Main.tables[chosenTable]![i].defaultValue);
                    if (Main.tables[chosenTable]![i].defaultValue.toString().contains("date")) {
                      String str = (await Main.db.rawQuery("${Main.tables[chosenTable]![i].defaultValue}"))[0].values.toList()[0].toString();
                      // print("Date of $str");
                      attrs.add(str);
                    } else {
                      attrs.add(Main.tables[chosenTable]![i].defaultValue);
                    }
                    vars += "${Main.tables[chosenTable]![i].name} = ?, ";
                  }
                  continue;
                }
                if (Main.tables[chosenTable]![i].type.contains("INT") || Main.tables[chosenTable]![i].type.contains("NUMERIC")) {
                  attrs.add(int.parse(controllers[i].text));
                } else {
                  attrs.add(controllers[i].text);
                }
                vars += "${Main.tables[chosenTable]![i].name} = ?, ";
              }
              print("attrs: $vars");
              vars = vars.substring(0, vars.length - 2);
              print("attrs: $vars");

              attrs.addAll(updateID.values.toList());

              String rules = "";
              updateID.forEach((key, value) {
                rules += "$key = ? AND ";
              });
              rules = rules.substring(0, rules.length - 4);

              try {

                await Main.db.rawInsert("UPDATE $chosenTable SET $vars WHERE $rules", attrs);
                showToast(
                  "Added successfully",
                  duration: const Duration(milliseconds: 1500),
                  position: ToastPosition.bottom,
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  radius: 100.0,
                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                );
              } catch (err, stacktrace) {
                print("ERROR: $err\n$stacktrace");
                showToast(
                  "ERROR: " + err.toString().substring(err.toString().indexOf("DatabaseException") + 18, err.toString().indexOf("(", err.toString().indexOf("DatabaseException") + 20)),
                  duration: const Duration(milliseconds: 5000),
                  position: ToastPosition.bottom,
                  backgroundColor: Colors.red.withOpacity(0.8),
                  radius: 100.0,
                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                );
              }
              setState(() {attrsToDisplay = [];updateID.clear();});
            },
          );
          int count = 0;
          Main.tables[chosenTable]?.forEach((element) {

            int maxLength = 100;
            if (element.type.contains("CHAR") || element.type.contains("NUMERIC")) {
              maxLength = element.size1;
            } else if (element.type.contains("INTEGER")) {
              maxLength = 10;
            } else if (element.type.contains("SMALLINT")) {
              maxLength = 6;
            } else if (element.type.contains("TIMESTAMP")) {
              maxLength = 19;
            } else if (element.type.contains("DATE")) {
              maxLength = 10;
            }

            String data = (attrsToDisplay[0] as Map).values.toList()[count].toString();
            controllers.add(TextEditingController(text: data == "null" ? "" : data));

            list.add(SizedBox(height: height * 0.01));
            list.add(
                TextField(
                  controller: controllers[controllers.length - 1],
                  style: TextStyle(color: Colors.white),
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    counterStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    labelText: element.name,
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: element.hintText.isNotEmpty ? element.hintText : 'Enter ${element.name}',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                )
            );

            count++;

          });

        }

        subpage = ListView(
          children: list,
        );

      }
      else if (modOP == 2) { // Delete

        Map deleteID = {};
        List<Widget> list = [];

        btn = TextButton.icon(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          label: const Text("Delete", style: TextStyle(color: Colors.red)),
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
          ),
          onPressed: () async {
            int count = 0;
            for (int i = 0; i < Main.tables[chosenTable]!.length ; i++) {
              var element = Main.tables[chosenTable]![i];
              if (controllers[count].text.isNotEmpty) {
                if (element.type.contains("NUMERIC") || element.type.contains("INT")) {
                  deleteID.addEntries([
                    MapEntry(element.name, int.parse(controllers[count].text))
                  ]);
                } else {
                  deleteID.addEntries([
                    MapEntry(element.name, controllers[count].text)
                  ]);
                }
              }
              count++;
            }

            String rules = "";
            List<dynamic> vals = deleteID.values.toList();
            deleteID.forEach((key, value) {
              rules += "$key = ? AND ";
            });
            rules = rules.substring(0, rules.length - 4);

            try {
              int count = await Main.db.rawDelete("DELETE FROM $chosenTable WHERE $rules", vals);
              showToast(
                "$count were deleted",
                duration: const Duration(milliseconds: 1500),
                position: ToastPosition.bottom,
                backgroundColor: Colors.blue.withOpacity(0.8),
                radius: 100.0,
                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
              );
            } catch(err, stacktrace) {
              print("$err\n$stacktrace");
            }
          },
        );

        for (int j = 0 ; j < Main.tables[chosenTable]!.length ; j++) {
          var element = Main.tables[chosenTable]![j];

          int maxLength = 100;
          if (element.type.contains("CHAR") || element.type.contains("NUMERIC")) {
            maxLength = element.size1;
          } else if (element.type.contains("INTEGER")) {
            maxLength = 10;
          } else if (element.type.contains("SMALLINT")) {
            maxLength = 6;
          } else if (element.type.contains("TIMESTAMP")) {
            maxLength = 19;
          } else if (element.type.contains("DATE")) {
            maxLength = 10;
          }

          controllers.add(TextEditingController());

          list.add(SizedBox(height: height * 0.01));
          list.add(
              TextField(
                controller: controllers[controllers.length - 1],
                style: TextStyle(color: Colors.white),
                maxLength: maxLength,
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  labelText: element.name,
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: element.hintText.isNotEmpty ? element.hintText : 'Enter ${element.name}',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              )
          );

        }

        subpage = ListView(
          children: list,
        );

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
                    attrsToDisplay = [];updateID.clear();
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
                    attrsToDisplay.clear();updateID.clear();
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
          Expanded(child: subpage),
          btn,
        ],
      );

    }
    else if (pageIndex == 1) {

      page = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Table: ", style: TextStyle(color: Main.appTheme.titleTextColor)),
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
                onChanged: (String? newValue) async {
                  chosenTable = newValue!;
                  chosenAttr = Main.tables[chosenTable]![0];
                  searchListOriginal = await Main.db.rawQuery("SELECT * FROM $chosenTable WHERE ${chosenAttr.name} = ?", [searchController.text]);
                  setState(() {

                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attribute: ", style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<AttributeForm>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: chosenAttr,
                items: Main.tables[chosenTable]!.map<DropdownMenuItem<AttributeForm>>((AttributeForm value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.name, style: TextStyle(color: Main.appTheme.titleTextColor)),
                  );
                }).toList(),
                onChanged: (AttributeForm? newValue) async {
                  chosenAttr = newValue!;
                  searchListOriginal = await Main.db.rawQuery("SELECT * FROM $chosenTable WHERE ${chosenAttr.name} = ?", [searchController.text]);
                  setState(() {
                  }); //
                },
              ),
            ],
          ),
          TextField(
            controller: searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              counterStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              labelText: chosenAttr.name,
              labelStyle: TextStyle(color: Colors.white),
              hintText: chosenAttr.hintText.isNotEmpty ? chosenAttr.hintText : 'Enter ${chosenAttr.name}',
              hintStyle: TextStyle(color: Colors.white),
            ),
            onChanged: (str) async {
              searchListOriginal = await Main.db.rawQuery("SELECT * FROM $chosenTable WHERE ${chosenAttr.name} = ?", [searchController.text]);
              print("The size of the search list is: ${searchListOriginal.length}");
              setState(() {});
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchListOriginal.length,
              itemBuilder: (context, index) => buildSearchResult(index),
            ),
          ),
        ],
      );

    }
    else { // then it should be 2, which is stats

      double netWorth = 0.0;

      page = ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Inventory Worth", style: TextStyle(color: Colors.white, fontSize: 22)),
              Text("${netWorth}K \$", style: TextStyle(color: Colors.green.shade700, fontSize: 26))
            ],
          ),
          SizedBox(
            height: height * 0.01,
          ),
          SizedBox(
            width: width,
            height: height * 0.8,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 30,
                minY: 0,
                maxY: 30,
                baselineX: 0.0,
                baselineY: 0.0,
                backgroundColor: Main.appTheme.scaffoldBackgroundColor.withRed(Main.appTheme.scaffoldBackgroundColor.red + 5),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xff37434d),
                      strokeWidth: 1
                    );
                  },
                  drawVerticalLine: true,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                        color: const Color(0xff37434d),
                        strokeWidth: 1
                    );
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: [
                      FlSpot(0, 4),
                      FlSpot(4, 16),
                      FlSpot(10, 5),
                      FlSpot(20, 20),
                    ],
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        reservedSize: 20,
                        showTitles: false,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 20,
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 20,
                      showTitles: false,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 20,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}K', style: TextStyle(fontSize: 10, color: Colors.white));
                      }
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

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
          onDestinationSelected: (int newIndex) async {
            setState(() {
              chosenAttr = Main.tables[chosenTable]![0];
              pageIndex = newIndex;
            });
          },
          destinations: [
            NavigationDestination(icon: Icon(Icons.mode_edit_outline, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.mode_edit, color: Main.appTheme.navIconColor), label: 'Modify'),
            NavigationDestination(icon: Icon(Icons.search_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.search, color: Main.appTheme.navIconColor), label: 'Search'),
            // NavigationDestination(icon: Icon(Icons.query_stats_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.query_stats, color: Main.appTheme.navIconColor), label: 'Stats'),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          child: page,
        ),
      ),
    );
  }

  ListTile buildSearchResult(int index) {

    ListTile tile = ListTile();

    switch (chosenTable) {

      case "Employee":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["employeeID"]} - " + searchListOriginal[index]["firstName"] + " " + searchListOriginal[index]["lastName"], style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["phoneNumber"]} - ${searchListOriginal[index]["email"]}\n${searchListOriginal[index]["jobTitle"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "Department":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["depID"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["depName"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "Office":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["officeNumber"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["officePhone"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "Customer":
        /*AttributeForm(name: "city", type: "VARCHAR", size1: 15),
      AttributeForm(name: "addressLine1", type: "VARCHAR", size1: 30),
      AttributeForm(name: "addressLine2", type: "VARCHAR", size1: 30),
      AttributeForm(name: "customerName", type: "VARCHAR", size1: 25, canBeNull: false),
      AttributeForm(name: "phoneNumber", type: "CHAR", size1: 11, canBeNull: false),
      AttributeForm(name: "state", type: "VARCHAR", size1: 15),
      AttributeForm(name: "postalCode", type: "INTEGER", canBeNull: false),
      AttributeForm(name: "employeeID", type: "INTEGER", tableFK: "Employee", nameFK: "employeeID"),*/
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["customerID"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
                '${searchListOriginal[index]["customerName"]}\n${searchListOriginal[index]["phoneNumber"]}'
                '${searchListOriginal[index]["state"]} ${searchListOriginal[index]["city"]}, ${searchListOriginal[index]["addressLine1"]} ${searchListOriginal[index]["addressLine2"]}'
                '${searchListOriginal[index]["postalCode"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "Orders":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["orderNumber"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["orderTime"]} - ${searchListOriginal[index]["paymentMethod"]}\n${searchListOriginal[index]["total"]} \$',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "OrderDetail":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("order No. ${searchListOriginal[index]["orderNumber"]} - Product No. ${searchListOriginal[index]["productCode"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["quantity"]} units',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "Products":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["productCode"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
                '${searchListOriginal[index]["productName"]}\n${searchListOriginal[index]["productDescription"]}'
                'Expires at ${searchListOriginal[index]["expireDate"]} with an amount of ${searchListOriginal[index]["amountInStock"]}'
                '${searchListOriginal[index]["productVendor"]}'
                'Bought at ${searchListOriginal[index]["purchasePrice"]} - Sold at ${searchListOriginal[index]["sellingPrice"]}'
                'Brought from ${searchListOriginal[index]["productLine"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "ProductLine":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["productLine"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            '${searchListOriginal[index]["productName"]}\n${searchListOriginal[index]["productDescription"]}'
                '${searchListOriginal[index]["lineVendor"]} - ${searchListOriginal[index]["lineCategory"]}'
                '${searchListOriginal[index]["description"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
      case "works_for":
        tile = ListTile(
          contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.005, width * 0.03, height * 0.005),
          title: Text("${searchListOriginal[index]["employeeID"]} works in ${searchListOriginal[index]["depID"]}", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            'works from ${searchListOriginal[index]["startHour"]} until ${searchListOriginal[index]["endHour"]}',
            style: const TextStyle(color: Colors.white),
          ),
        );
        break;
    }

    return tile;

  }

  @override
  void dispose() async {

    await Main.db.close();

    super.dispose();

  }

}
