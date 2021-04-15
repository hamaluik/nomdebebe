import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';
import 'package:nomdebebe/keys.dart';
import 'package:nomdebebe/blocs/names/names.dart';

class DataReset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsReset,
          title: Text("Reset"),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.undoAlt),
          onTap: () async {
            bool? doit = await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: Text('Reset all data?'),
                        content: const Text(
                            'This will reset all your names and settings to as if you\'d never used the app.'),
                        actions: [
                          TextButton(
                            child: const Text('CANCEL'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('RESET'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ]));
            if (doit == true) {
              BlocProvider.of<SettingsBloc>(context)
                  .add(SettingsFactoryReset());
              BlocProvider.of<NamesBloc>(context).add(NamesFactoryReset());
              BlocProvider.of<SharingBloc>(context)
                  .add(SharingEventUpdateLikedNames(List.empty()));
            }
          });
    });
  }
}
