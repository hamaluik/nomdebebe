import 'package:namekit/models/sex.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  const SettingsRepository._(this._prefs);

  static Future<SettingsRepository> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SettingsRepository._(prefs);
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
}
