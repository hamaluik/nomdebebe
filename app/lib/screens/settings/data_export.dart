import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/keys.dart';
import 'package:share/share.dart';

class DataExport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        return ListTile(
            key: Keys.settingsExport,
            title: Text("Export"),
            trailing: namesState.likedNames.isEmpty
                ? null
                : Icon(FontAwesomeIcons.chevronRight),
            leading: Icon(FontAwesomeIcons.table),
            subtitle: namesState.likedNames.isEmpty
                ? Text("(not until you like some names first!)")
                : null,
            onTap: namesState.likedNames.isEmpty
                ? null
                : () async {
                    String nameList =
                        namesState.likedNames.map((n) => n.name).join(", ");
                    try {
                      await Share.share(nameList,
                          subject: "My favourite bébé names");
                    } catch (e) {
                      print("error: " + e.toString());
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: SingleChildScrollView(
                                  child: Text(
                                      "Something went wrong when trying to export your list of favourite babynames, sorry!")),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK 🤷'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  });
      });
    });
  }
}
