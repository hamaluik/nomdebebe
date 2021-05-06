abstract class Filter {
  const Filter();
  String get query => "";
  List<Object> get args => List.empty();
}

class IDFilter extends Filter {
  final List<int> ids;
  const IDFilter(this.ids);

  @override
  String get query => "id in (" + ids.map((_) => "?").join(",") + ")";

  @override
  List<Object> get args => ids;
}

class LikeFilter extends Filter {
  final int? _like;
  const LikeFilter._(this._like);

  @override
  String get query => _like == null ? "like is null" : "like = ?";

  @override
  List<Object> get args => _like == null ? List.empty() : [_like!];

  static LikeFilter undecided = LikeFilter._(null);
  static LikeFilter liked = LikeFilter._(1);
  static LikeFilter disliked = LikeFilter._(0);
}

class SexFilter extends Filter {
  final String _sex;
  const SexFilter._(this._sex);

  @override
  String get query => "sex = ?";

  @override
  List<Object> get args => [this._sex];

  static SexFilter male = SexFilter._('M');
  static SexFilter female = SexFilter._('F');
}

class SearchFilter extends Filter {
  final String _name;
  const SearchFilter(this._name);

  @override
  String get query => "name like ?";

  @override
  List<Object> get args => ["%" + this._name + "%"];
}

/// This class is a bit delicate at the moment. Don't feed it malformed letter lists please.
class FirstLettersFilter extends Filter {
  final List<String> _letters;
  const FirstLettersFilter(this._letters);

  @override
  String get query => _letters.isEmpty
      ? ""
      : ("(" + _letters.map((l) => "name like ?").join(" OR ") + ")");

  @override
  List<Object> get args =>
      _letters.isEmpty ? List.empty() : _letters.map((l) => l + "%").toList();
}

/// This class is a bit delicate at the moment. Don't feed it malformed decade lists please.
class DecadesFilter extends Filter {
  final List<int> _decades;
  final int? _maxRank;
  const DecadesFilter(this._decades, this._maxRank);

  @override
  String get query => _decades.isEmpty
      ? ""
      : ("(" +
          _decades.map((d) => "name_decades.decade=?").join(" OR ") +
          ") AND decade_rank <= ?");

  @override
  List<Object> get args => _decades.isEmpty
      ? List.empty()
      : (_decades.cast<Object>() + <Object>[_maxRank ?? 1000000]);
}
