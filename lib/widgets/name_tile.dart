import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/models/sex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameTile extends StatelessWidget {
  final Name name;

  const NameTile(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      return Padding(
          padding: EdgeInsets.all(2),
          child: Card(
              color: sexToColour(name.sex),
              elevation: 2,
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(name.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center))));
    });
  }
}
