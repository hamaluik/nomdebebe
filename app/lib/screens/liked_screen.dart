import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/widgets/name_tile.dart';

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

        return Column(children: [
          Container(
              height: MediaQuery.of(context)
                  .padding
                  .top), // TODO: something more natural?
          Expanded(
              child: ReorderableListView.builder(
                  itemBuilder: (BuildContext context, int index) => NameTile(
                      namesState.likedNames[index],
                      key: Key("__liked_name_tile_" +
                          namesState.likedNames[index].id.toString()),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                                onPressed: () =>
                                    BlocProvider.of<NamesBloc>(context).add(
                                        NamesDislike(
                                            namesState.likedNames[index])),
                                icon: Icon(FontAwesomeIcons.solidThumbsDown,
                                    color: Colors.white),
                                label: Text("Dislike",
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        ?.copyWith(color: Colors.white))),
                            TextButton.icon(
                                onPressed: () =>
                                    BlocProvider.of<NamesBloc>(context).add(
                                        NamesUndecide(
                                            namesState.likedNames[index])),
                                icon: Icon(FontAwesomeIcons.question,
                                    color: Colors.white),
                                label: Text("Un-decide",
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        ?.copyWith(color: Colors.white))),
                          ])),
                  itemCount: namesState.likedNames.length,
                  onReorder: (int oldIndex, int newIndex) =>
                      BlocProvider.of<NamesBloc>(context)
                          .add(NamesLikedRank(oldIndex, newIndex))))
        ]);
      });
    });
  }
}
