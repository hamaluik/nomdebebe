import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/keys.dart';

class DataExport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsExport,
          title: Text("Export"),
          trailing: Icon(FontAwesomeIcons.fileExport),
          leading: Icon(FontAwesomeIcons.table),
          onTap: () async {});
    });
  }
}
