import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/keys.dart';
import 'package:namekit/themes.dart';

String _themeDisplay(ThemeType? theme) {
  switch (theme) {
    case null:
      return "Follow device settings";
    case ThemeType.light:
      return "Light";
    case ThemeType.dark:
      return "Dark";
    case ThemeType.black:
      return "Black";
  }
}

IconData _themeIcon(ThemeType? theme) {
  switch (theme) {
    case null:
      return FontAwesomeIcons.adjust;
    case ThemeType.light:
      return FontAwesomeIcons.solidSun;
    case ThemeType.dark:
      return FontAwesomeIcons.solidCircle;
    case ThemeType.black:
      return FontAwesomeIcons.solidMoon;
  }
}

class ThemeOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsSexOptions,
          title: Text("Theme"),
          subtitle: Text(_themeDisplay(state.theme)),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(_themeIcon(state.theme)),
          onTap: () async {
            ThemeType? oldTheme = state.theme;
            ThemeType? newTheme = await showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                builder: (BuildContext context) =>
                    ListView(shrinkWrap: true, children: <Widget>[
                      RadioListTile<ThemeType?>(
                          key: Keys.settingsThemeAuto,
                          secondary: Icon(_themeIcon(null)),
                          title: Text(_themeDisplay(null)),
                          value: null,
                          groupValue: oldTheme,
                          onChanged: (ThemeType? t) =>
                              Navigator.pop(context, t)),
                      RadioListTile<ThemeType?>(
                          key: Keys.settingsThemeLight,
                          secondary: Icon(_themeIcon(ThemeType.light)),
                          title: Text(_themeDisplay(ThemeType.light)),
                          value: ThemeType.light,
                          groupValue: oldTheme,
                          onChanged: (ThemeType? t) =>
                              Navigator.pop(context, t)),
                      RadioListTile<ThemeType?>(
                          key: Keys.settingsThemeDark,
                          secondary: Icon(_themeIcon(ThemeType.dark)),
                          title: Text(_themeDisplay(ThemeType.dark)),
                          value: ThemeType.dark,
                          groupValue: oldTheme,
                          onChanged: (ThemeType? t) =>
                              Navigator.pop(context, t)),
                      RadioListTile<ThemeType?>(
                          key: Keys.settingsThemeBlack,
                          secondary: Icon(_themeIcon(ThemeType.black)),
                          title: Text(_themeDisplay(ThemeType.black)),
                          value: ThemeType.black,
                          groupValue: oldTheme,
                          onChanged: (ThemeType? t) =>
                              Navigator.pop(context, t)),
                    ]));
            BlocProvider.of<SettingsBloc>(context)
                .add(SettingsSetTheme(newTheme));
          });
    });
  }
}
