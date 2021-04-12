import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/widgets/name_tile.dart';
import 'package:namekit/repositories/names_repository.dart';

class LikedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      NamesRepository repo =
          BlocProvider.of<NamesBloc>(context).namesRepository;
      return Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
          itemCount: repo.countLikedNames(),
          itemBuilder: (BuildContext context, int i) {
            List<Name> names = repo.getNames(skip: i, count: 1);
            if (names.length < 1) return Container();
            return NameTile(names.first);
          },
        )),
      ]);
    });
  }
}
