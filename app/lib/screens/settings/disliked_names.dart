import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/keys.dart';
import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:nomdebebe/widgets/name_tile_quick.dart';
import 'package:nomdebebe/main.dart';

class DislikedNames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: Keys.settingsDisliked,
        title: Text("Disliked names"),
        trailing: Icon(FontAwesomeIcons.chevronRight),
        leading: Icon(FontAwesomeIcons.solidThumbsDown),
        onTap: () => context
            .findAncestorStateOfType<ScreenContainerState>()
            ?.navigatorKey
            .currentState
            ?.pushNamed("disliked"));
  }
}
