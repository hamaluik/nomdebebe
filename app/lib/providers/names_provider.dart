import 'dart:collection';
import 'dart:io';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nomdebebe/models/filter.dart';
import 'package:sqflite/sqflite.dart';

class NamesProvider {
  final Database _db;
  static const int CURRENT_VERSION = 1;

  static Future<NamesProvider> load() async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = p.join(documents.path, "nomdebebe.db");
    if (await FileSystemEntity.type(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(p.join("assets", "nomdebebe.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    }

    return NamesProvider(await _initDatabase(path));
  }

  static Future<Database> _initDatabase(String path) async {
    Database db = await openDatabase(path);
    while (await db.getVersion() < CURRENT_VERSION) {
      if (await db.getVersion() == 0) {
        db.execute("begin transaction");
        try {
          db.execute('''
            alter table names add column like boolean default null''');
          db.execute('''
            create table name_ranks(
              id integer not null primary key,
              rank integer default null,
              foreign key(id) references names(id)
            )''');
          db.setVersion(1);
        } catch (e) {
          db.execute("rollback transaction");
          throw e;
        }
        db.execute("commit transaction");
      }
    }

    db.execute("PRAGMA foreign_keys = ON");

    return db;
  }

  NamesProvider(this._db);

  Future<void> factoryReset() async {
    await _db.transaction((Transaction t) async {
      await t.execute("delete from name_ranks");
      await t.execute("update names set like = null");
      return null;
    }, exclusive: true);
  }

  String _formatFilterQuery(List<Filter> filters) {
    if (filters.isEmpty) return "";
    return "WHERE " + filters.map((f) => f.query).join(" AND ");
  }

  bool _hasDecadesFilter(List<Filter> filters) {
    for (Filter filter in filters) {
      if (filter is DecadesFilter) return true;
    }
    return false;
  }

  Future<int> countNames(List<Filter> filters) async {
    String query = _hasDecadesFilter(filters)
        ? "select count(distinct names.id) as count from names left join name_decades on name_decades.name_id = names.id ${_formatFilterQuery(filters)}"
        : "select count(distinct names.id) as count from names ${_formatFilterQuery(filters)}";
    List<Object> args = filters.expand((f) => f.args).toList();

    var results = await _db.rawQuery(query, args);
    int count = results.first['count'] as int;

    //print("countNames: `$query` / `$args` => $count");
    return count;
  }

  Future<List<Name>> getNames(List<Filter> filters, int skip, int count) async {
    String query = _hasDecadesFilter(filters)
        ? "select names.id as id, names.name as name, names.sex as sex, names.like as like, sum(name_decades.count) as count from names inner join name_decades on name_decades.name_id=names.id ${_formatFilterQuery(filters)} group by names.id order by count desc limit ? offset ?"
        : "select names.id as id, names.name as name, names.sex as sex, names.like as like from names ${_formatFilterQuery(filters)} limit ? offset ?";
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];

    List<Map<String, Object?>> results = await _db.rawQuery(query, args);
    List<Name> names = results.map((Map<String, Object?> row) {
      int id = row['id'] as int;
      String name = row['name'] as String;
      String s = row['sex'] as String;
      int? l = row['like'] as int?;
      bool? like;
      if (l == 1)
        like = true;
      else if (l == 0) like = false;
      return Name(id, name, sexFromString(s), like);
    }).toList();

    //print("getNames: `$query` / `$args` => $names");
    return names;
  }

  Future<void> setNameLike(int id, bool? like) async {
    await _db.transaction((Transaction t) async {
      int? l;
      if (like == true)
        l = 1;
      else if (like == false) l = 0;
      await t.execute("update names set like = ? where id = ?", [l, id]);

      if (like == true)
        await t.execute(
            "insert or ignore into name_ranks(id, rank) values(?, null)", [id]);
      else
        await t.execute("delete from name_ranks where id=?", [id]);
    });
  }

  Future<void> rankLikedNames(List<int> sortedIds) async {
    await _db.transaction((Transaction t) async {
      for (int i = 0; i < sortedIds.length; i++) {
        await t.execute(
            "update name_ranks set rank=? where id=?", [i, sortedIds[i]]);
      }
    });
  }

  Future<List<int>> getRankedLikedNameIds(
      List<Filter> filters, int skip, int count) async {
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];
    // TODO: don't include decade filters here?
    List<Map<String, Object?>> results = await _db.rawQuery(
        "select names.id as id from names inner join name_ranks on name_ranks.id = names.id inner join name_decades on name_decades.name_id = names.id ${_formatFilterQuery(filters)} group by names.id order by name_ranks.rank is null, name_ranks.rank asc limit ? offset ?",
        args);
    return results.map((Map<String, Object?> r) => r['id'] as int).toList();
  }

  Future<List<Name>> getRankedLikedNames(
      List<Filter> filters, int skip, int count) async {
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];
    // TODO: don't include decade filters here?
    List<Map<String, Object?>> results = await _db.rawQuery(
        "select names.id as id, names.name as name, names.sex as sex, names.like as like from names inner join name_ranks on name_ranks.id = names.id inner join name_decades on name_decades.name_id = names.id ${_formatFilterQuery(filters)} group by names.id order by name_ranks.rank is null, name_ranks.rank asc limit ? offset ?",
        args);
    return results.map((Map<String, Object?> r) {
      int id = r['id'] as int;
      String name = r['name'] as String;
      String s = r['sex'] as String;
      int? l = r['like'] as int?;
      bool? like;
      if (l == 1)
        like = true;
      else if (l == 0) like = false;
      return Name(id, name, sexFromString(s), like);
    }).toList();
  }

  Future<LinkedHashMap<int, int>> getDecadeCounts() async {
    List<Map<String, Object?>> results = await _db.rawQuery(
        "select decade, sum(count) as decade_sum from name_decades group by decade");
    LinkedHashMap<int, int> decades = LinkedHashMap();
    for (Map<String, Object?> row in results) {
      int decade = row['decade'] as int;
      int sum = row['decade_sum'] as int;
      decades[decade] = sum;
    }
    return decades;
  }

  Future<LinkedHashMap<int, int>> getNameDecadeCounts(int id) async {
    List<Map<String, Object?>> results = await _db.rawQuery(
        "select decade, count from name_decades where name_id=? order by decade asc",
        [id]);
    LinkedHashMap<int, int> decades = LinkedHashMap();
    for (Map<String, Object?> row in results) {
      int decade = row['decade'] as int;
      int count = row['count'] as int;
      decades[decade] = count;
    }
    return decades;
  }
}
