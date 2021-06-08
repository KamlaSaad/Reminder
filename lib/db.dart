import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SQL_Helper {
  static SQL_Helper dbHelper;
  static Database _database;

  SQL_Helper._createInstance();

  factory SQL_Helper() {
    if (dbHelper == null) {
      dbHelper = SQL_Helper._createInstance();
    }
    return dbHelper;
  }

  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'reminder.db'),
      onCreate: (db, version) async {
        //create tables
        await db.execute(
            'CREATE TABLE Events(ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DATE TEXT)');
      },
      version: 1,
    );
  }

  Future<List> getEvents() async {
    Database db = await createDatabase();

    //var result1 =  await db.rawQuery("SELECT * FROM $tableName ORDER BY $_id ASC");
    var result = await db.query('Events', orderBy: "DATE ASC");
    return result;
  }

  Future<int> addEvent(String title, String date) async {
    Database db = await createDatabase();
    var result = await db
        .rawInsert("INSERT INTO Events(TITLE,DATE)VALUES('$title','$date')");
    return result;
  }

  Future<int> updateEvent(int id, String title, String date) async {
    Database db = await createDatabase();
    var result = await db.rawUpdate(
        "UPDATE Events SET TITLE='$title',DATE='$date' WHERE ID='$id'");
    return result;
  }

  Future<int> deleteEvent(int id) async {
    var db = await createDatabase();
    int result = await db.rawDelete("DELETE FROM Events WHERE ID = $id");
    return result;
  }

  Future<int> deleteAllEvents() async {
    var db = await createDatabase();
    int result = await db.rawDelete("DELETE FROM Events");
    return result;
  }

  Future<List> search(String title) async {
    var db = await createDatabase();
    //var result = await db.query("Events", where: "TITLE=?", whereArgs: [title]);
    if (title != null) {
      var result =
          await db.rawQuery("SELECT * FROM EVENTS WHERE TITLE LIKE '%$title%'");
      return result;
    }
  }
}
