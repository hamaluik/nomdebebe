import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/models/filter.dart';
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
      return DefaultTabController(
          length: 2,
          child: Column(children: <Widget>[
            Expanded(
                child: TabBarView(children: [
              ListView.builder(
                itemCount: repo.countLikedNames(filters: [SexFilter.male]),
                itemBuilder: (BuildContext context, int i) {
                  List<Name> names = repo
                      .getNames(filters: [SexFilter.male], skip: i, count: 1);
                  if (names.length < 1) return Container();
                  return NameTile(names.first);
                },
              ),
              ListView.builder(
                itemCount: repo.countLikedNames(filters: [SexFilter.female]),
                itemBuilder: (BuildContext context, int i) {
                  List<Name> names = repo
                      .getNames(filters: [SexFilter.female], skip: i, count: 1);
                  if (names.length < 1) return Container();
                  return NameTile(names.first);
                },
              ),
            ])),
            TabBar(tabs: [
              Tab(icon: Icon(FontAwesomeIcons.male)),
              Tab(icon: Icon(FontAwesomeIcons.female)),
            ]),
          ]));
    });
  }
}
