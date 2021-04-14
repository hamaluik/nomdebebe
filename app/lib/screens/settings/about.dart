import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/keys.dart';
import 'package:about/about.dart';
import 'package:flutter_svg/flutter_svg.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsAbout,
          title: Text("About"),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.dna),
          onTap: () => showAboutPage(
                context: context,
                values: {
                  'version': '1.0',
                  'year': DateTime.now().year.toString(),
                },
                applicationLegalese: 'Copyright © Kenton Hamaluik, {{ year }}',
                applicationDescription:
                    const Text('Simple, private, babyname helper.'),
                children: <Widget>[
                  MarkdownPageListTile(
                    icon: Icon(FontAwesomeIcons.readme),
                    title: const Text('Readme'),
                    filename: 'README.md',
                  ),
                  LicensesPageListTile(
                    icon: Icon(FontAwesomeIcons.scroll),
                  ),
                ],
                applicationIcon: SvgPicture.asset(
                  "assets/icon.svg",
                  semanticsLabel: "Namekit logo",
                  height: 100,
                ),
              ));
    });
  }
}
