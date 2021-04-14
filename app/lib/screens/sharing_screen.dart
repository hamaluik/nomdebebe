import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';

class SharingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        return BlocBuilder<SharingBloc, SharingState>(
            builder: (BuildContext context, SharingState sharingState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              sharingState.myID == null
                  ? Text("...loading...")
                  : Text("Your ID for sharing: " + sharingState.myID!)
            ],
          );
        });
      });
    });
  }
}
