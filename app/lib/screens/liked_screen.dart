import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/widgets/name_tile_link.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';

class LikedScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikedScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        if (namesState.likedNames.isEmpty) {
          return Center(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("You haven't liked any names yet!",
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center)));
        }

        if (settingsState.pinkAndBlue && settingsState.sexPreference == null) {
          return DefaultTabController(
              length: 2,
              child: Column(children: [
                Container(
                    height: MediaQuery.of(context)
                        .padding
                        .top), // TODO: something more natural?
                Expanded(
                  child: TabBarView(children: [
                    ReorderableListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          Name name = namesState.likedNames
                              .where((n) => n.sex == Sex.female)
                              .elementAt(index);

                          return Hero(
                              key: Key("__name_explorer_" + name.id.toString()),
                              tag: "nameDetailsHero_" + name.id.toString(),
                              child: NameTileLink(
                                name,
                                onTap: (Name name) => Navigator.of(context)
                                    .push(MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            NameDetailsScreen(name))),
                              ));
                        },
                        itemCount: namesState.likedNames
                            .where((n) => n.sex == Sex.female)
                            .length,
                        onReorder: (int oldIndex, int newIndex) =>
                            BlocProvider.of<NamesBloc>(context).add(
                                NamesLikedRank(
                                    Sex.female, oldIndex, newIndex))),
                    ReorderableListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          Name name = namesState.likedNames
                              .where((n) => n.sex == Sex.male)
                              .elementAt(index);

                          return Hero(
                              key: Key("__name_explorer_" + name.id.toString()),
                              tag: "nameDetailsHero_" + name.id.toString(),
                              child: NameTileLink(
                                name,
                                onTap: (Name name) => Navigator.of(context)
                                    .push(MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            NameDetailsScreen(name))),
                              ));
                        },
                        itemCount: namesState.likedNames
                            .where((n) => n.sex == Sex.male)
                            .length,
                        onReorder: (int oldIndex, int newIndex) =>
                            BlocProvider.of<NamesBloc>(context).add(
                                NamesLikedRank(Sex.male, oldIndex, newIndex))),
                  ]),
                ),
                TabBar(tabs: [
                  Tab(icon: Icon(FontAwesomeIcons.venus)),
                  Tab(icon: Icon(FontAwesomeIcons.mars)),
                ]),
              ]));
        } else {
          return Column(children: [
            Container(
                height: MediaQuery.of(context)
                    .padding
                    .top), // TODO: something more natural?
            Expanded(
                child: ReorderableListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      Name name = namesState.likedNames.elementAt(index);

                      return Hero(
                          key: Key("__name_explorer_" + name.id.toString()),
                          tag: "nameDetailsHero_" + name.id.toString(),
                          child: NameTileLink(
                            name,
                            onTap: (Name name) => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        NameDetailsScreen(name))),
                          ));
                    },
                    itemCount: namesState.likedNames.length,
                    onReorder: (int oldIndex, int newIndex) =>
                        BlocProvider.of<NamesBloc>(context)
                            .add(NamesLikedRank(null, oldIndex, newIndex))))
          ]);
        }
      });
    });
  }
}
