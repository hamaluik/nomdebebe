import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/screens/sharing/setup.dart';
import 'package:nomdebebe/widgets/name_tile_link.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';

class SharingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SharingScreenState();
}

class _SharingScreenState extends State<SharingScreen>
    with TickerProviderStateMixin {
  late TabController mainTabController;
  late TabController sexTabController;

  @override
  void initState() {
    super.initState();
    mainTabController = TabController(length: 3, vsync: this);
    sexTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    mainTabController.dispose();
    sexTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        return BlocBuilder<SharingBloc, SharingState>(
            builder: (BuildContext context, SharingState sharingState) {
          if (!sharingState.enableSharing) {
            return Center(
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (_) => Colors.pink.shade600),
                    ),
                    onPressed: () => BlocProvider.of<SharingBloc>(context)
                        .add(SharingEventEnableDisable(true)),
                    icon: Icon(FontAwesomeIcons.share, color: Colors.white),
                    label: Text("Enable names sharing",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.copyWith(color: Colors.white))));
          }

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

          return Column(children: <Widget>[
            Expanded(
                child: TabBarView(
              controller: mainTabController,
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
                        child: settingsState.pinkAndBlue
                            ? Column(children: [
                                Expanded(
                                    child: TabBarView(
                                  controller: sexTabController,
                                  children: [
                                    ListView(
                                        children: _matchedNames(
                                            namesState, sharingState,
                                            sex: Sex.female)),
                                    ListView(
                                        children: _matchedNames(
                                            namesState, sharingState,
                                            sex: Sex.male)),
                                  ],
                                )),
                                TabBar(controller: sexTabController, tabs: [
                                  Tab(icon: Icon(FontAwesomeIcons.venus)),
                                  Tab(icon: Icon(FontAwesomeIcons.mars)),
                                ])
                              ])
                            : ListView(
                                children:
                                    _matchedNames(namesState, sharingState),
                                physics:
                                    const AlwaysScrollableScrollPhysics())),
                RefreshIndicator(
                    onRefresh: () async => BlocProvider.of<SharingBloc>(context)
                        .add(SharingEventRefresh()),
                    child: settingsState.pinkAndBlue
                        ? Column(children: [
                            Expanded(
                                child: TabBarView(
                              controller: sexTabController,
                              children: [
                                ListView.builder(
                                    itemCount: sharingState.partnerNames
                                        .where((Name n) => n.sex == Sex.female)
                                        .length,
                                    itemBuilder: (BuildContext context,
                                            int index) =>
                                        NameTileLink(
                                          sharingState.partnerNames
                                              .where((Name n) =>
                                                  n.sex == Sex.female)
                                              .elementAt(index),
                                          onTap: (Name name) => Navigator.of(
                                                  context)
                                              .push(MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      NameDetailsScreen(name))),
                                        ),
                                    physics:
                                        const AlwaysScrollableScrollPhysics()),
                                ListView.builder(
                                    itemCount: sharingState.partnerNames
                                        .where((Name n) => n.sex == Sex.male)
                                        .length,
                                    itemBuilder: (BuildContext context,
                                            int index) =>
                                        NameTileLink(
                                          sharingState.partnerNames
                                              .where(
                                                  (Name n) => n.sex == Sex.male)
                                              .elementAt(index),
                                          onTap: (Name name) => Navigator.of(
                                                  context)
                                              .push(MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      NameDetailsScreen(name))),
                                        ),
                                    physics:
                                        const AlwaysScrollableScrollPhysics()),
                              ],
                            )),
                            TabBar(controller: sexTabController, tabs: [
                              Tab(icon: Icon(FontAwesomeIcons.venus)),
                              Tab(icon: Icon(FontAwesomeIcons.mars)),
                            ])
                          ])
                        : ListView.builder(
                            itemCount: sharingState.partnerNames.length,
                            itemBuilder: (BuildContext context, int index) =>
                                NameTileLink(
                                  sharingState.partnerNames[index],
                                  onTap: (Name name) => Navigator.of(context)
                                      .push(MaterialPageRoute<void>(
                                          builder: (_) =>
                                              NameDetailsScreen(name))),
                                ),
                            physics: const AlwaysScrollableScrollPhysics())),
                SetupScreen(),
              ],
            )),
            TabBar(controller: mainTabController, tabs: [
              Tab(icon: Icon(FontAwesomeIcons.equals), text: "Matches"),
              Tab(
                  icon: Icon(FontAwesomeIcons.userFriends),
                  text: "Partner's List"),
              Tab(icon: Icon(FontAwesomeIcons.qrcode), text: "Sharing Code"),
            ])
          ]);
        });
      });
    });
  }

  List<Widget> _matchedNames(NamesState namesState, SharingState sharingState,
      {Sex? sex}) {
    // do this the verbose way so we can collect the ranks of the two names
    List<MatchedName> matches = [];
    for (int i = 0; i < namesState.likedNames.length; i++) {
      for (int j = 0; j < sharingState.partnerNames.length; j++) {
        if (namesState.likedNames[i].name ==
            sharingState.partnerNames[j].name) {
          if (sex != null) {
            if (namesState.likedNames[i].sex == sex) {
              matches.add(MatchedName(namesState.likedNames[i], i, j));
            }
          } else {
            matches.add(MatchedName(namesState.likedNames[i], i, j));
          }
          break;
        }
      }
    }

    matches.sort((MatchedName a, MatchedName b) => a.order.compareTo(b.order));
    return matches
        .map((m) => NameTileLink(
              m.name,
              key: Key("__liked_names_" + m.name.id.toString()),
              onTap: (Name name) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => NameDetailsScreen(name))),
            ))
        .toList();
  }
}

class MatchedName {
  final Name name;
  final int order;

  MatchedName(this.name, int a, int b) : order = a + b;
}
