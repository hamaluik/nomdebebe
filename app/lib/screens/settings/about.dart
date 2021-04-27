import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/keys.dart';
import 'package:about/about.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
          onTap: () async {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            showAboutPage(
              context: context,
              values: {
                'version': packageInfo.version + "+" + packageInfo.buildNumber,
                'year': DateTime.now().year.toString(),
              },
              applicationLegalese: 'Copyright © Kenton Hamaluik, {{ year }}',
              applicationDescription: const Text(
                  'A simple, private tool to help pick a baby name.'),
              children: <Widget>[
                LicensesPageListTile(
                  icon: Icon(FontAwesomeIcons.scroll),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.code),
                  title: Text("Source Code"),
                  onTap: () => launch("https://github.com/hamaluik/nomdebebe/"),
                ),
              ],
              applicationIcon: SvgPicture.asset(
                "assets/icon.svg",
                semanticsLabel: "Nom de Bébé logo",
                height: 100,
              ),
            );
          });
    });
  }
}
