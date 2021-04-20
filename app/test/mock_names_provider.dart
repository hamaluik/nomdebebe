import 'package:nomdebebe/providers/names_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class MockNamesProvider extends NamesProvider {
  MockNamesProvider(Database db) : super(db);

  static MockNamesProvider load() {
    Database db = sqlite3.openInMemory();

    db.execute(
        "CREATE TABLE names(id integer not null primary key autoincrement, name text not null, sex text not null, unique(name, sex))");
    db.execute(
        "CREATE TABLE name_decades(name_id integer not null, count integer, decade integer, decade_rank integer, unique(name_id, decade), foreign key(name_id) references names(id));");

    PreparedStatement ns = db
        .prepare("insert into names(name, sex) values(?, ?)", persistent: true);
    ns.execute(["Mary", "F"]);
    ns.execute(["John", "M"]);
    ns.execute(["Paul", "M"]);
    ns.execute(["Rachel", "F"]);
    ns.dispose();

    PreparedStatement ds = db.prepare(
        "insert into name_decades(name_id, count, decade, decade_rank) values(?, ?, ?, ?)",
        persistent: true);
    ds.execute([1, 100, 188, 1]);
    ds.execute([2, 97, 188, 2]);
    ds.execute([3, 86, 188, 3]);
    ds.execute([4, 64, 188, 4]);
    ds.execute([1, 67, 201, 3]);
    ds.execute([2, 42, 201, 4]);
    ds.execute([3, 130, 201, 2]);
    ds.execute([4, 150, 201, 1]);
    ds.dispose();

    return MockNamesProvider(db);
  }
}
