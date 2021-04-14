import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/keys.dart';

class DislikedNames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsDisliked,
          title: Text("Disliked names"),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.solidThumbsDown),
          onTap: () async {});
    });
  }
}
