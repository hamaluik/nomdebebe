import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/keys.dart';
import 'package:namekit/models/sex.dart';

String _sexDisplay(Sex? sex) {
  switch (sex) {
    case null:
      return "No preference";
    case Sex.male:
      return "Masculine names only";
    case Sex.female:
      return "Feminine names only";
  }
}

IconData _sexIcon(Sex? sex) {
  switch (sex) {
    case null:
      return FontAwesomeIcons.venusMars;
    case Sex.male:
      return FontAwesomeIcons.mars;
    case Sex.female:
      return FontAwesomeIcons.venus;
  }
}

class SexOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsSexOptions,
          title: Text("Sex"),
          subtitle: Text(_sexDisplay(state.sexPreference)),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(_sexIcon(state.sexPreference)),
          onTap: () async {
            Sex? oldSex = state.sexPreference;
            Sex? newSex = await showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                builder: (BuildContext context) =>
                    ListView(shrinkWrap: true, children: <Widget>[
                      RadioListTile<Sex?>(
                          key: Keys.settingsSexOptionsNoPreference,
                          secondary: Icon(_sexIcon(null)),
                          title: Text(_sexDisplay(null)),
                          value: null,
                          groupValue: oldSex,
                          onChanged: (Sex? s) => Navigator.pop(context, s)),
                      RadioListTile<Sex?>(
                          key: Keys.settingsSexOptionsFemale,
                          secondary: Icon(_sexIcon(Sex.female)),
                          title: Text(_sexDisplay(Sex.female)),
                          value: Sex.female,
                          groupValue: oldSex,
                          onChanged: (Sex? s) => Navigator.pop(context, s)),
                      RadioListTile<Sex?>(
                          key: Keys.settingsSexOptionsMale,
                          secondary: Icon(_sexIcon(Sex.male)),
                          title: Text(_sexDisplay(Sex.male)),
                          value: Sex.male,
                          groupValue: oldSex,
                          onChanged: (Sex? s) => Navigator.pop(context, s)),
                    ]));
            BlocProvider.of<SettingsBloc>(context).add(SettingsSetSex(newSex));
          });
    });
  }
}
