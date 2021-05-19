import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/keys.dart';
import 'package:about/about.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class About extends StatelessWidget {
  MarkdownStyleSheet styleMarkdown(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return MarkdownStyleSheet(
      a: TextStyle(
          color: Colors.pink.shade600, decoration: TextDecoration.underline),
      p: theme.textTheme.bodyText2,
      code: theme.textTheme.bodyText2!.copyWith(
        backgroundColor: theme.cardTheme.color ?? theme.cardColor,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyText2!.fontSize! * 0.85,
      ),
      h1: theme.textTheme.headline5,
      h2: theme.textTheme.headline6,
      h3: theme.textTheme.subtitle1,
      h4: theme.textTheme.bodyText1,
      h5: theme.textTheme.bodyText1,
      h6: theme.textTheme.bodyText1,
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      del: const TextStyle(decoration: TextDecoration.lineThrough),
      blockquote: theme.textTheme.bodyText2,
      img: theme.textTheme.bodyText2,
      checkbox: theme.textTheme.bodyText2!.copyWith(
        color: theme.primaryColor,
      ),
      blockSpacing: 8.0,
      listIndent: 24.0,
      listBullet: theme.textTheme.bodyText2,
      listBulletPadding: const EdgeInsets.only(right: 4),
      tableHead: const TextStyle(fontWeight: FontWeight.w600),
      tableBody: theme.textTheme.bodyText2,
      tableHeadAlign: TextAlign.center,
      tableBorder: TableBorder.all(
        color: theme.dividerColor,
        width: 1,
      ),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      tableCellsDecoration: const BoxDecoration(),
      blockquotePadding: const EdgeInsets.all(8.0),
      blockquoteDecoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2.0),
      ),
      codeblockPadding: const EdgeInsets.all(8.0),
      codeblockDecoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 5.0,
            color: theme.dividerColor,
          ),
        ),
      ),
    );
  }

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
                MarkdownPageListTile(
                    icon: Icon(FontAwesomeIcons.info),
                    title: const Text("Names"),
                    filename: "NAMES.md",
                    styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                    styleSheet: styleMarkdown(context),
                    tapHandler: URLTapHandler()),
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

class URLTapHandler extends MarkdownTapHandler {
  URLTapHandler() : super();

  @override
  FutureOr<void> onTap(
      BuildContext context, String text, String? href, String title) async {
    await launch(href ?? text);
  }
}
