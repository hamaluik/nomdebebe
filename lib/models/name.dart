import 'package:equatable/equatable.dart';
import 'package:namekit/models/sex.dart';

class Name extends Equatable {
  final int id;
  final String name;
  final Sex sex;
  final bool? like;

  Name(this.id, this.name, this.sex, this.like);

  @override
  List<Object?> get props => [id, name, sex, like];

  Name makeLiked() {
    return Name(id, name, sex, true);
  }

  Name makeDisliked() {
    return Name(id, name, sex, false);
  }

  Name makeUndecided() {
    return Name(id, name, sex, null);
  }
}
