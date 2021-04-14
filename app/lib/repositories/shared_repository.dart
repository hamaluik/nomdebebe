import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SharedRepository {
  static final String rootURI = "https://nomdebebe.hamaluik.dev";
  final SharedPreferences _prefs;
  final http.Client _client;

  SharedRepository._(this._prefs) : _client = http.Client();

  static Future<SharedRepository> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedRepository._(prefs);
  }

  Future<String?> get myID async {
    if (_prefs.containsKey("myID") && _prefs.containsKey("mySecret")) {
      return _prefs.getString("myID");
    }

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

    return id;
  }

  String? get parterID {
    if (!_prefs.containsKey("partnerID")) return null;
    return _prefs.getString("partnerID");
  }

  set parterID(String? id) {
    if (id == null) {
      _prefs.remove("partnerID");
    } else {
      _prefs.setString("parterID", id);
    }
  }

  Future<void> setLikedNames(List<String> names) async {
    String? id = await myID;
    if (id == null) throw "Failed to obtain my ID!";
    String secret = _prefs.getString("mySecret")!;

    String body = jsonEncode(names);
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

  Future<List<String>?> getParterNames(String parterID) async {
    Uri uri = Uri.parse(rootURI + "/id/" + Uri.encodeComponent(parterID));
    http.Response resp = await http.get(uri);

    if (resp.statusCode != 200) {
      print("Error getting parter names: ${resp.statusCode} => ${resp.body}");
      return null;
    }

    var body = jsonDecode(resp.body);
    if (!(body is List)) {
      print("Malformed response from sharing server: ${resp.body}");
      return null;
    }

    List<String> names = body.cast<String>();
    return names;
  }
}
