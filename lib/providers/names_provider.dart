import 'dart:io';
import 'package:namekit/models/name.dart';
import 'package:namekit/models/sex.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

Sex _sexFromString(String s) {
  if (s.toLowerCase() == 'm') return Sex.male;
  return Sex.female;
}

//String _sexToString(Sex s) {
//if (s == Sex.male) return 'M';
//return 'F';
//}

class NamesProvider {
  final Database _db;
  static const int CURRENT_VERSION = 1;

  static Future<NamesProvider> load({bool? isTest}) async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = p.join(documents.path, "namekit.db");
    if (await FileSystemEntity.type(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(p.join("assets", "namekit.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    }

    Database db;
    db = sqlite3.open(path, mutex: true);
    return NamesProvider._(db);
  }

  NamesProvider._(this._db) {
    while (_db.userVersion < CURRENT_VERSION) {
      if (_db.userVersion == 0) {
        _db.execute("begin transaction");
        try {
          _db.execute('''
            alter table names add column like boolean default null''');
          _db.userVersion = 1;
        } catch (e) {
          _db.execute("rollback transaction");
          throw e;
        }
        _db.execute("commit transaction");
      }
    }

    _db.execute("PRAGMA foreign_keys = ON");
  }

  List<Name> _getNames(String query) {
    PreparedStatement stmt = _db.prepare(query);
    ResultSet results = stmt.select();
    List<Name> names = results.map((Row r) {
      int id = r['id'];
      String name = r['name'];
      String s = r['sex'];
      int? l = r['like'];
      bool? like;
      if (l == 1)
        like = true;
      else if (l == 0) like = false;
      return Name(id, name, _sexFromString(s), like);
    }).toList();
    stmt.dispose();
    return names;
  }

  List<Name> getUndecidedNames() {
    return _getNames(
        "select id, name, sex, like from names where like is null");
  }

  List<Name> getLikedNames() {
    return _getNames("select id, name, sex, like from names where like = true");
  }

  List<Name> getDislikedNames() {
    return _getNames(
        "select id, name, sex, like from names where like = false");
  }

  List<Name> getAllNames() {
    return _getNames("select id, name, sex, like from names");
  }

  void setNameLike(int id, bool? like) {
    PreparedStatement stmt =
        _db.prepare("update names set like = ? where id = ?");
    int? l;
    if (like == true)
      l = 1;
    else if (like == false) l = 0;
    stmt.execute([l, id]);
    stmt.dispose();
  }
}
