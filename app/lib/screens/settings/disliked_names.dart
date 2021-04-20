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

class DislikedNames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return ListTile(
          key: Keys.settingsDisliked,
          title: Text("Disliked names"),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.solidThumbsDown),
          onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return BlocBuilder<NamesBloc, NamesState>(
                    builder: (BuildContext context, NamesState namesState) {
                  NamesRepository repo =
                      BlocProvider.of<NamesBloc>(context).namesRepository;

                  int dislikedCount = namesState.namesCount -
                      namesState.likedNamesCount -
                      namesState.undecidedNamesCount;

                  if (dislikedCount == 0) {
                    return Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("You haven't disliked any names yet!",
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.center)));
                  }

                  return Column(children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: dislikedCount,
                            itemBuilder: (BuildContext context, int index) {
                              List<Name> disliked = repo.getNames(
                                  filters: <Filter>[LikeFilter.disliked] +
                                      settingsState.filters,
                                  skip: index,
                                  count: 1);
                              return NameTileQuick(
                                disliked.first,
                                trailing: TextButton.icon(
                                    onPressed: () =>
                                        BlocProvider.of<NamesBloc>(context)
                                            .add(NamesLike(disliked.first)),
                                    icon: Icon(FontAwesomeIcons.solidHeart,
                                        color: Colors.white),
                                    label: Text("Like",
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            ?.copyWith(color: Colors.white))),
                                leading: TextButton.icon(
                                    onPressed: () =>
                                        BlocProvider.of<NamesBloc>(context)
                                            .add(NamesUndecide(disliked.first)),
                                    icon: Icon(FontAwesomeIcons.question,
                                        color: Colors.white),
                                    label: Text("Un-decide",
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            ?.copyWith(color: Colors.white))),
                              );
                            }))
                  ]);
                });
              })));
    });
  }
}
