class AttributeForm {

  // static Map<int, String> typeToStr = {
  //   0 : "SMALLINT",
  //   1 : "INTEGER",
  //   2 : "CHAR",
  //   3 : "VARCHAR",
  //   4 : "DATE",
  // };

  String name;
  String type;
  int size1, size2; // for ex.: CHAR(size1) or NUMERIC(size1, size2)
  String tableFK; // if it is empty, then this property is not a FK, if it is then it has the table name
  String nameFK; // the of the FK inside tableFK
  bool isPK;
  bool canBeNull; // if it is FK or PK, then it is false
  dynamic defaultValue;

  AttributeForm({required this.name, required this.type, this.size1 = -1, this.size2 = -1,
    this.tableFK = "", this.nameFK = "", this.isPK = false, this.canBeNull = true, this.defaultValue}) {

    if (isPK || tableFK.isNotEmpty) {
      canBeNull = false;
    }

  }

}
