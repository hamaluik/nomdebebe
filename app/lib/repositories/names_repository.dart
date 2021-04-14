import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/providers/names_provider.dart';

class NamesRepository {
  final NamesProvider _namesProvider;

  NamesRepository(this._namesProvider);

  List<Name> getNames({List<Filter>? filters, int skip = 0, int count = 20}) {
    return _namesProvider.getNames(filters ?? List.empty(), skip, count);
  }

  Name? getNextUndecidedName({List<Filter>? filters}) {
    List<Name> names = _namesProvider.getNames(
        <Filter>[LikeFilter.undecided] + (filters ?? List.empty()), 0, 1);
    if (names.isEmpty) return null;
    return names[0];
  }

  Name likeName(Name name) {
    _namesProvider.setNameLike(name.id, true);
    return name.makeLiked();
  }

  Name dislikeName(Name name) {
    _namesProvider.setNameLike(name.id, false);
    return name.makeDisliked();
  }

  Name undecideName(Name name) {
    _namesProvider.setNameLike(name.id, null);
    return name.makeUndecided();
  }

  int countTotalNames({List<Filter>? filters}) {
    return _namesProvider.countNames(filters ?? List.empty());
  }

  int countUndecidedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.undecided] + (filters ?? List.empty()));
  }

  int countLikedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.liked] + (filters ?? List.empty()));
  }

  int countDislikedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.disliked] + (filters ?? List.empty()));
  }

  List<Name> getRankedLikedNames({List<Filter>? filters}) {
    return _namesProvider.getRankedLikedNames(
        filters ?? List.empty(), 0, 1000000);
  }

  void swapLikedNamesRanks(int oldRank, int newRank, {List<Filter>? filters}) {
    List<int> ids = _namesProvider.getRankedLikedNameIds(
        filters ?? List.empty(), 0, 1000000);
    int id = ids.removeAt(oldRank);
    ids.insert(newRank, id);
    _namesProvider.rankLikedNames(ids);
  }

  void factoryReset() {
    _namesProvider.factoryReset();
  }
}
