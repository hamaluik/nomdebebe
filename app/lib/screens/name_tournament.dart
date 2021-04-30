import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/screens/tournament/tournament_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/widgets/name_tile_link.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';

class NameTournament extends StatefulWidget {
  final Sex? sex;

  NameTournament({this.sex});

  @override
  State<StatefulWidget> createState() => _NameTournamentState();
}

class _NameTournamentState extends State<NameTournament> {
  late TournamentBloc bloc;
  late Random random;

  @override
  void initState() {
    super.initState();
    bloc = TournamentBloc.load(BlocProvider.of<NamesBloc>(context), widget.sex);
    random = Random();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
        bloc: bloc,
        builder: (BuildContext context, TournamentState state) {
          if (state.pendingPairs.isEmpty) {
            List<int> rankedIDs = state.nameScores.keys.toList();
            rankedIDs.sort(
                (a, b) => state.nameScores[b]!.compareTo(state.nameScores[a]!));

            return BlocBuilder<NamesBloc, NamesState>(
                builder: (BuildContext context, NamesState namesState) {
              return SafeArea(
                  child: Column(children: [
                Text("Here are your favourite names, in order:",
                    style: Theme.of(context).textTheme.bodyText2),
                Expanded(
                    child: ListView.builder(
                        itemCount: rankedIDs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Name? name;
                          try {
                            name = namesState.likedNames.firstWhere(
                                (Name n) => n.id == rankedIDs[index]);
                          } catch (_) {}

                          if (name == null)
                            return Container(
                                key: Key("__name_explorer_" +
                                    rankedIDs[index].toString()));

                          return NameTileLink(name,
                              onTap: (Name name) => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          NameDetailsScreen(name))),
                              key: Key("__name_explorer_" +
                                  rankedIDs[index].toString()));
                        })),
                Container(height: 8),
                Text("Do you want to save this ranking?",
                    style: Theme.of(context).textTheme.bodyText2),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon:
                              Icon(FontAwesomeIcons.times, color: Colors.white),
                          label: Text("No",
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(color: Colors.white))),
                      TextButton.icon(
                        onPressed: () {
                          bloc.add(TournamentCommit());
                          Navigator.of(context).pop();
                        },
                        icon: Icon(FontAwesomeIcons.check, color: Colors.white),
                        label: Text("Save",
                            style: Theme.of(context)
                                .textTheme
                                .button
                                ?.copyWith(color: Colors.white)),
                      ),
                    ]),
              ]));
            });
          }

          bool aFirst = random.nextBool();
          NamePair pair = state.pendingPairs.first;
          return SafeArea(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settings) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Which name do you prefer:",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.center),
                                Expanded(
                                    child: _NameChoice(
                                        pair, aFirst, settings, bloc)),
                                Text("or:",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.center),
                                Expanded(
                                    child: _NameChoice(
                                        pair, !aFirst, settings, bloc)),
                                Text(
                                    "(${state.pendingPairs.length} choices left)",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    textAlign: TextAlign.center),
                              ]))));
        });
  }
}

class _NameChoice extends StatelessWidget {
  final NamePair pair;
  final bool isA;
  final SettingsState settings;
  final TournamentBloc bloc;

  const _NameChoice(this.pair, this.isA, this.settings, this.bloc);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Card(
            color: sexToColour(
                context, isA ? pair.a.sex : pair.b.sex, settings.pinkAndBlue),
            elevation:
                Theme.of(context).brightness == Brightness.dark ? 0 : null,
            child: InkWell(
                onTap: () {
                  bloc.add(TournamentRank(pair, isA));
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                      child: Text(isA ? pair.a.name : pair.b.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center)),
                ))));
  }
}
