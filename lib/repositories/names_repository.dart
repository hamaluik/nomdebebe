import 'package:namekit/models/name.dart';
import 'package:namekit/providers/names_provider.dart';

class NamesRepository {
  final NamesProvider _namesProvider;

  NamesRepository(this._namesProvider);

  List<Name> getAllNames() {
    return _namesProvider.getAllNames();
  }

  List<Name> getNames(bool? liked) {
    // make it explicit we're testing for nulls on a boolean, etc
    if (liked == null) {
      return _namesProvider.getUndecidedNames();
    } else if (liked == true) {
      return _namesProvider.getLikedNames();
    } else {
      return _namesProvider.getDislikedNames();
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
}
