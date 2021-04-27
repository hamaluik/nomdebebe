import 'dart:collection';

import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/providers/names_provider.dart';

class NamesRepository {
  final NamesProvider _namesProvider;

  NamesRepository(this._namesProvider);

  Future<List<Name>> getNames(
      {List<Filter>? filters, int skip = 0, int count = 20}) {
    return _namesProvider.getNames(filters ?? List.empty(), skip, count);
  }

  //Future<Name?> getNextUndecidedName({List<Filter>? filters}) async {
  //List<Name> names = await _namesProvider.getNames(
  //<Filter>[LikeFilter.undecided] + (filters ?? List.empty()), 0, 1);
  //if (names.isEmpty) return null;
  //return names[0];
  //}

  Future<Name> likeName(Name name) async {
    await _namesProvider.setNameLike(name.id, true);
    return name.makeLiked();
  }

  Future<Name> dislikeName(Name name) async {
    await _namesProvider.setNameLike(name.id, false);
    return name.makeDisliked();
  }

  Future<Name> undecideName(Name name) async {
    await _namesProvider.setNameLike(name.id, null);
    return name.makeUndecided();
  }

  Future<int> countTotalNames({List<Filter>? filters}) {
    return _namesProvider.countNames(filters ?? List.empty());
  }

  Future<int> countUndecidedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.undecided] + (filters ?? List.empty()));
  }

  Future<int> countLikedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.liked] + (filters ?? List.empty()));
  }

  Future<int> countDislikedNames({List<Filter>? filters}) {
    return _namesProvider
        .countNames(<Filter>[LikeFilter.disliked] + (filters ?? List.empty()));
  }

  Future<List<Name>> getRankedLikedNames({List<Filter>? filters}) {
    return _namesProvider.getRankedLikedNames(
        filters ?? List.empty(), 0, 1000000);
  }

  Future<void> swapLikedNamesRanks(int oldRank, int newRank,
      {List<Filter>? filters}) async {
    List<int> ids = await _namesProvider.getRankedLikedNameIds(
        filters ?? List.empty(), 0, 1000000);
    int id = ids.removeAt(oldRank);
    ids.insert(newRank > oldRank ? newRank - 1 : newRank, id);
    return _namesProvider.rankLikedNames(ids);
  }

  Future<void> factoryReset() {
    return _namesProvider.factoryReset();
  }

  Future<LinkedHashMap<int, int>> getDecadeCounts() {
    return _namesProvider.getDecadeCounts();
  }

  Future<LinkedHashMap<int, int>> getNameDecadeCounts(int id) {
    return _namesProvider.getNameDecadeCounts(id);
  }
}
