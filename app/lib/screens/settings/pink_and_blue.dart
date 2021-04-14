import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/keys.dart';

class PinkAndBlue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return SwitchListTile.adaptive(
        key: Keys.settingsPinkAndBlue,
        title: Text("Colour names according to sex"),
        subtitle: Text("Pink for feminine, blue for masculine names"),
        value: state.pinkAndBlue,
        secondary: Icon(FontAwesomeIcons.palette),
        onChanged: (bool on) => BlocProvider.of<SettingsBloc>(context)
            .add(SettingsSetPinkAndBlue(on)),
      );
    });
  }
}
