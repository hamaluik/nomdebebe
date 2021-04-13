import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/models/filter.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/widgets/name_tile.dart';
import 'package:namekit/repositories/names_repository.dart';

class LikedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        NamesRepository namesRepository =
            BlocProvider.of<NamesBloc>(context).namesRepository;
        return Column(children: <Widget>[
          Expanded(
              child: ListView.builder(
            itemCount: namesState.likedNamesCount,
            itemBuilder: (BuildContext context, int i) {
              List<Name> names = namesRepository.getNames(
                  filters: settingsState.filters + [LikeFilter.liked],
                  skip: i,
                  count: 1);
              if (names.length < 1) return Container();
              return NameTile(names.first);
            },
          )),
        ]);
      });
    });
  }
}
