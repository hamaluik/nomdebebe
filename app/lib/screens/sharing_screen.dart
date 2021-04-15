import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';
import 'package:nomdebebe/screens/sharing/setup.dart';
import 'package:nomdebebe/widgets/name_tile.dart';
import 'package:nomdebebe/models/name.dart';

class SharingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        return BlocBuilder<SharingBloc, SharingState>(
            builder: (BuildContext context, SharingState sharingState) {
          if (sharingState.myID == null) {
            return Center(
                child: Text(
                    "Something went wrong sharing your liked names list",
                    style: Theme.of(context).textTheme.caption));
          }

          if (sharingState.partnerID == null ||
              sharingState.partnerNames.isEmpty) {
            return SetupScreen();
          }

          List<Widget> matched = _matchedNames(namesState, sharingState);

          return DefaultTabController(
            length: 3,
            child: Column(children: <Widget>[
              Expanded(
                  child: TabBarView(
                children: [
                  matched.isEmpty
                      ? Center(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                  "You don't have any matches with your partner yet!",
                                  style: Theme.of(context).textTheme.headline4,
                                  textAlign: TextAlign.center)))
                      : RefreshIndicator(
                          onRefresh: () async =>
                              BlocProvider.of<SharingBloc>(context)
                                  .add(SharingEventRefresh()),
                          child: ListView(
                              children: _matchedNames(namesState, sharingState),
                              physics: const AlwaysScrollableScrollPhysics())),
                  RefreshIndicator(
                      onRefresh: () async =>
                          BlocProvider.of<SharingBloc>(context)
                              .add(SharingEventRefresh()),
                      child: ListView.builder(
                          itemCount: sharingState.partnerNames.length,
                          itemBuilder: (BuildContext context, int index) =>
                              NameTile(sharingState.partnerNames[index]),
                          physics: const AlwaysScrollableScrollPhysics())),
                  SetupScreen(),
                ],
              )),
              TabBar(tabs: [
                Tab(icon: Icon(FontAwesomeIcons.equals), text: "Matches"),
                Tab(
                    icon: Icon(FontAwesomeIcons.userFriends),
                    text: "Partner's List"),
                Tab(icon: Icon(FontAwesomeIcons.qrcode), text: "Sharing Code"),
              ])
            ]),
          );
        });
      });
    });
  }

  List<Widget> _matchedNames(NamesState namesState, SharingState sharingState) {
    // do this the verbose way so we can collect the ranks of the two names
    List<MatchedName> matches = [];
    for (int i = 0; i < namesState.likedNames.length; i++) {
      for (int j = 0; j < sharingState.partnerNames.length; j++) {
        if (namesState.likedNames[i].name ==
            sharingState.partnerNames[j].name) {
          matches.add(MatchedName(namesState.likedNames[i], i, j));
          break;
        }
      }
    }

    matches.sort((MatchedName a, MatchedName b) => a.order.compareTo(b.order));
    return matches
        .map((m) =>
            NameTile(m.name, key: Key("__liked_names_" + m.name.id.toString())))
        .toList();
  }
}

class MatchedName {
  final Name name;
  final int order;

  MatchedName(this.name, int a, int b) : order = a + b;
}
