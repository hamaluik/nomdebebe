import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SharedRepository {
  static final String rootURI = "https://nomdebebe.hamaluik.dev";
  final NamesRepository namesRepository;
  final SharedPreferences _prefs;
  final http.Client _client;

  SharedRepository._(this.namesRepository, this._prefs)
      : _client = http.Client();

  static Future<SharedRepository> load(NamesRepository namesRepository) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedRepository._(namesRepository, prefs);
  }

  Future<String?> get myID async {
    if (_prefs.containsKey("myID") && _prefs.containsKey("mySecret")) {
      print("retrieved stored myID: ${_prefs.getString('myID')}");
      return _prefs.getString("myID");
    }

    print("Getting new id...");
    Uri uri = Uri.parse(rootURI + "/id/new");
    http.Response resp = await http.get(uri);

    if (resp.statusCode != 200) {
      print("Error from sharing server: ${resp.statusCode} => ${resp.body}");
      return null;
    }
    var body = jsonDecode(resp.body);
    if (!(body is Map)) {
      print("Unexpected response from sharing server: ${resp.body}");
      return null;
    }

    String? id = body["id"];
    String? secret = body["secret"];
    if (id == null || secret == null) {
      print("Expected id and secret, but are null?");
      return null;
    }

    await _prefs.setString("myID", id);
    await _prefs.setString("mySecret", secret);

    print("Obtained ID $id and secret");

    return id;
  }

  Future<String?> resetMyID() async {
    await _prefs.remove("myID");
    await _prefs.remove("mySecret");
    return myID;
  }

  String? get partnerID {
    if (!_prefs.containsKey("partnerID")) {
      print("no partner id in storage");
      return null;
    }
    print("partner id: ${_prefs.getString('partnerID')}");
    return _prefs.getString("partnerID");
  }

  set partnerID(String? id) {
    if (id == null) {
      _prefs.remove("partnerID");
      print("partner id cleared");
    } else {
      _prefs.setString("partnerID", id);
      print("partner id set to $id");
    }
  }

  Future<void> setLikedNames(List<Name> names) async {
    String? id = await myID;
    if (id == null) throw "Failed to obtain my ID!";
    String secret = _prefs.getString("mySecret")!;

    String body = jsonEncode(names
        .map((Name n) => {'name': n.name, 'sex': sexToString(n.sex)})
        .toList());
    Uri uri = Uri.parse(rootURI +
        "/names/" +
        Uri.encodeComponent(id) +
        "?secret=" +
        Uri.encodeQueryComponent(secret));
    http.Response resp = await _client
        .post(uri, body: body, headers: {"Content-Type": "application/json"});

    if (resp.statusCode != 200) {
      print("Failed to share liked names: ${resp.statusCode} => ${resp.body}");
      throw "Failed to share liked names";
    }
  }

  Future<List<Name>?> getParterNames(String partnerID) async {
    Uri uri = Uri.parse(rootURI + "/names/" + Uri.encodeComponent(partnerID));
    http.Response resp = await http.get(uri);

    if (resp.statusCode != 200) {
      print("Error getting partner names: ${resp.statusCode} => ${resp.body}");
      return null;
    }

    var body = jsonDecode(resp.body);
    if (!(body is List)) {
      print("Malformed response from sharing server: ${resp.body}");
      return null;
    }

    List<Map<String, dynamic>> nameRaws = body.cast<Map<String, dynamic>>();
    List<Name> names = nameRaws
        .map((n) => Name(-1, n['name'] ?? "?",
            n['sex'] == 'F' ? Sex.female : Sex.male, false))
        .toList();
    return names;
  }
}
