import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:test/test.dart';
import 'mock_names_provider.dart';
import 'package:nomdebebe/repositories/names_repository.dart';

void main() {
  test("can initialize repo", () {
    NamesRepository(MockNamesProvider.load());
  });

  test("can get names", () {
    NamesRepository repo = NamesRepository(MockNamesProvider.load());

    List<Name> names = repo.getNames(count: 4);
    expect(names.length, equals(4));
    for (Name name in names) {
      expect(name.id, greaterThan(0));
      expect(name.name.isNotEmpty, equals(true));
    }
  });

  test("can get filtered names", () {
    NamesRepository repo = NamesRepository(MockNamesProvider.load());

    List<Name> names = repo.getNames(filters: <Filter>[
      SexFilter.female,
      FirstLettersFilter(['M'])
    ]);
    expect(names.length, equals(1));
    expect(names.first.name, equals("Mary"));
    expect(names.first.sex, equals(Sex.female));
  });

  group("can decide on names", () {
    NamesRepository repo = NamesRepository(MockNamesProvider.load());

    test("can like a name", () {
      Name? _u = repo.getNextUndecidedName();
      expect(_u, isNotNull);
      Name undecided = _u!;
      expect(undecided.like, isNull);

      repo.likeName(undecided);

      List<Name> names = repo.getNames();
      Name found = names.firstWhere((n) => n.id == undecided.id);
      expect(found.like, equals(true));
    });

    test("can dislike a name", () {
      Name? _u = repo.getNextUndecidedName();
      expect(_u, isNotNull);
      Name undecided = _u!;
      expect(undecided.like, isNull);

      repo.dislikeName(undecided);

      List<Name> names = repo.getNames();
      Name found = names.firstWhere((n) => n.id == undecided.id);
      expect(found.like, equals(false));
    });

    test("can count names by status", () {
      int total = repo.countTotalNames();
      int undecided = repo.countUndecidedNames();
      int liked = repo.countLikedNames();
      int disliked = repo.countDislikedNames();

      expect(total, equals(4));
      expect(undecided, equals(2));
      expect(liked, equals(1));
      expect(disliked, equals(1));
    });

    test("can undecide a name", () {
      List<Name> likedNames = repo.getNames(filters: [LikeFilter.liked]);
      expect(likedNames.isNotEmpty, equals(true));
      Name liked = likedNames.first;

      repo.undecideName(liked);

      List<Name> names = repo.getNames();
      Name found = names.firstWhere((n) => n.id == liked.id);
      expect(found.like, isNull);
    });
  });
}
