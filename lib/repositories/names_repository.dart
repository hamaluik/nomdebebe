import 'package:namekit/models/name.dart';
import 'package:namekit/providers/names_provider.dart';

class NamesRepository {
  final NamesProvider _namesProvider;

  NamesRepository(this._namesProvider);

  List<Name> getAllNames({int skip = 0, int count = 20}) {
    return _namesProvider.getAllNames(skip, count);
  }

  Name? getNextUndecidedName() {
    return _namesProvider.getNextUndecidedName();
  }

  List<Name> getNames(bool? liked, {int skip = 0, int count = 20}) {
    // make it explicit we're testing for nulls on a boolean, etc
    if (liked == null) {
      return _namesProvider.getUndecidedNames(skip, count);
    } else if (liked == true) {
      return _namesProvider.getLikedNames(skip, count);
    } else {
      return _namesProvider.getDislikedNames(skip, count);
    }
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

  int countTotalNames() {
    return _namesProvider.countTotalNames();
  }

  int countUndecidedNames() {
    return _namesProvider.countUndecidedNames();
  }
}
