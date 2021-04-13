import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/models/filter.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/widgets/name_tile.dart';
import 'package:namekit/repositories/names_repository.dart';
import 'package:reorderables/reorderables.dart';

//class LikedScreen extends StatelessWidget {
//@override
//Widget build(BuildContext context) {
//return BlocBuilder<SettingsBloc, SettingsState>(
//builder: (BuildContext context, SettingsState settingsState) {
//return BlocBuilder<NamesBloc, NamesState>(
//builder: (BuildContext context, NamesState namesState) {
//NamesRepository namesRepository =
//BlocProvider.of<NamesBloc>(context).namesRepository;
//return Column(children: <Widget>[
//Expanded(
//child: ListView.builder(
//itemCount: namesState.likedNamesCount,
//itemBuilder: (BuildContext context, int i) {
//List<Name> names = namesRepository.getNames(
//filters: settingsState.filters + [LikeFilter.liked],
//skip: i,
//count: 1);
//if (names.length < 1) return Container();
//return NameTile(names.first);
//},
//)),
//]);
//});
//});
//}
//}

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
        ScrollController _scrollController =
            PrimaryScrollController.of(context) ?? ScrollController();
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: namesState.likedNames.isEmpty
                      ? Center(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text("You haven't liked any names yet!",
                                  style: Theme.of(context).textTheme.headline4,
                                  textAlign: TextAlign.center)))
                      : CustomScrollView(
                          controller: _scrollController,
                          slivers: <Widget>[
                              ReorderableSliverList(
                                  delegate:
                                      ReorderableSliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (index < 0 ||
                                          index >= namesState.likedNames.length)
                                        return Container();
                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: NameTile(namesState
                                                  .likedNames[index])));
                                    },
                                    childCount: namesState.likedNamesCount,
                                  ),
                                  onReorder: (int oldIndex, int newIndex) {
                                    BlocProvider.of<NamesBloc>(context).add(
                                        NamesLikedRank(oldIndex, newIndex));
                                  })
                            ])),
            ]);
      });
    });
  }
}
