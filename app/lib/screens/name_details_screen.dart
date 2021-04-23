import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';

class NameDetailsScreen extends StatelessWidget {
  final Name name;
  const NameDetailsScreen(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (BuildContext context, SettingsState settingsState) =>
                Hero(
                    tag: "nameDetailsHero",
                    child: Card(
                        color: sexToColour(
                            context, name.sex, settingsState.pinkAndBlue),
                        elevation: 2,
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: <Widget>[
                              Text(name.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(color: Colors.white),
                                  textAlign: TextAlign.center),
                              Expanded(
                                  child: Container(color: Colors.green[400])),
                            ]))))));
  }
}
