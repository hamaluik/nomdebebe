import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  const SettingsRepository._(this._prefs);

  static Future<SettingsRepository> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SettingsRepository._(prefs);
  }

  void factoryReset() {
    _prefs.remove("sex");
    _prefs.remove("firstLetters");
    _prefs.remove("theme");
  }

  Sex? get sex {
    if (!_prefs.containsKey("sex")) return null;
    String? s = _prefs.getString("sex");
    Sex? sex;
    if (s != null) sex = sexFromString(s);
    return sex;
  }

  set sex(Sex? sex) {
    String? s = sex == null ? null : sexToString(sex);
    if (s == null) {
      _prefs.remove("sex");
    } else {
      _prefs.setString("sex", s);
    }
  }

  List<String> get firstLetters {
    if (!_prefs.containsKey("firstLetters")) return List.empty();
    List<String> firstLetters =
        _prefs.getStringList("firstLetters") ?? List.empty();
    return firstLetters;
  }

  set firstLetters(List<String> firstLetters) {
    List<String> letters = firstLetters
        .where((l) => l.isNotEmpty)
        .map((l) => l.substring(0, 1).toUpperCase())
        .toList();
    _prefs.setStringList("firstLetters", letters);
  }

  List<int> get decades {
    if (!_prefs.containsKey("decades")) return List.empty();
    List<String> decades = _prefs.getStringList("decades") ?? List.empty();
    return decades.map((d) => int.tryParse(d) ?? 201).toList();
  }

  set decades(List<int> decades) {
    _prefs.setStringList("decades", decades.map((d) => d.toString()).toList());
  }

  int? get maxRank {
    if (!_prefs.containsKey("maxRank")) return null;
    return _prefs.getInt("maxRank");
  }

  set maxRank(int? maxRank) {
    if (maxRank == null) {
      _prefs.remove("maxRank");
    } else {
      _prefs.setInt("maxRank", maxRank);
    }
  }

  ThemeType? get theme {
    if (!_prefs.containsKey("theme")) return ThemeType.light;
    String? t = _prefs.getString("theme");
    if (t == "light")
      return ThemeType.light;
    else if (t == "dark")
      return ThemeType.dark;
    else if (t == "black")
      return ThemeType.black;
    else if (t == "auto") return null;
    return null;
  }

  set theme(ThemeType? theme) {
    switch (theme) {
      case null:
        _prefs.setString("theme", "auto");
        break;
      case ThemeType.light:
        _prefs.setString("theme", "light");
        break;
      case ThemeType.dark:
        _prefs.setString("theme", "dark");
        break;
      case ThemeType.black:
        _prefs.setString("theme", "black");
        break;
    }
  }

  bool get pinkAndBlue {
    if (!_prefs.containsKey("pinkAndBlue")) return true;
    bool? pAB = _prefs.getBool("pinkAndBlue");
    return pAB ?? true;
  }

  set pinkAndBlue(bool pinkAndBlue) {
    _prefs.setBool("pinkAndBlue", pinkAndBlue);
  }
}
