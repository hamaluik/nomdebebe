import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/models/sex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Color sexToColour(Sex sex) {
  switch (sex) {
    case Sex.male:
      return Colors.lightBlue.shade600;
    case Sex.female:
      return Colors.pink.shade600;
  }
}

class NameCard extends StatelessWidget {
  final Name name;

  const NameCard(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      return Dismissible(
          key: Key(name.id.toString()),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              BlocProvider.of<NamesBloc>(context).add(NamesLike(name));
            } else {
              BlocProvider.of<NamesBloc>(context).add(NamesDislike(name));
            }
          },
          resizeDuration: null,
          background: Container(
              child: Icon(FontAwesomeIcons.solidHeart,
                  size: 128, color: Colors.white)),
          secondaryBackground: Container(
              child: Icon(FontAwesomeIcons.solidThumbsDown,
                  size: 128, color: Colors.white)),
          child: Card(
              color: Colors.transparent,
              //elevation: 4.0,
              child: Container(
                  decoration: BoxDecoration(
                      color: sexToColour(name.sex),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Column(
                    children: <Widget>[
                      AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                              child: Center(
                                  child: Text(name.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .copyWith(color: Colors.white)))))
                    ],
                  ))));
    });
  }
}
