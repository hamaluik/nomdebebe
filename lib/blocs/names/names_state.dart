import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';

class NamesState extends Equatable {
  final List<Name> names;
  const NamesState(this.names);

  @override
  List<Object> get props => [names];
}
