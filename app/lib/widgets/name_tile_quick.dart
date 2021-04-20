import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameTileQuick extends StatelessWidget {
  final Name name;
  final Widget? leading;
  final Widget? trailing;

  const NameTileQuick(this.name, {Key? key, this.leading, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (BuildContext context, SettingsState settingsState) {
        return Padding(
            padding: EdgeInsets.all(2),
            child: Card(
                color:
                    sexToColour(context, name.sex, settingsState.pinkAndBlue),
                elevation: 2,
                child: Row(children: [
                  leading ?? Container(),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(name.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center))),
                  trailing ?? Container(),
                ])));
      });
    });
  }
}
