import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/box.dart';
import 'package:nomdebebe/keys.dart';

String _decadesDisplay(HashSet<int> decades) {
  if (decades.isEmpty) return "Any decade";

  List<String> decadesSorted =
      decades.map((d) => (d * 10).toString() + "s").toList();
  decadesSorted.sort();
  return decadesSorted.join(",");
}

class DecadeOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsDecades,
          title: Text(state.decades.isEmpty
              ? "Names from"
              : (state.maxRank == null
                  ? "Only names popular in the"
                  : "Only show the top ${state.maxRank} names from the")),
          subtitle: Text(_decadesDisplay(state.decades)),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.solidCalendar),
          onTap: () async {
            HashSet<int> _decades = HashSet.from(state.decades);
            Box<int?> _maxRank = Box(state.maxRank);
            bool? save = await showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                builder: (BuildContext context) => Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, null);
                                  },
                                  child: Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text("SAVE"))
                            ]),
                      ),
                      _MaxRankChooser(_maxRank),
                      Expanded(child: _DecadeCheckboxes(_decades)),
                    ]));
            if (save == true) {
              print("setting decades to: " + _decades.join(","));
              BlocProvider.of<SettingsBloc>(context)
                  .add(SettingsSetDecades(_decades, _maxRank.value));
            }
          });
    });
  }
}

class _MaxRankChooser extends StatefulWidget {
  final Box<int?> maxRank;
  _MaxRankChooser(this.maxRank);

  @override
  State<StatefulWidget> createState() => _MaxRankChooserState(maxRank);
}

class _MaxRankChooserState extends State<_MaxRankChooser> {
  Box<int?> maxRank;
  _MaxRankChooserState(this.maxRank);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text("10"),
            Expanded(
                child: Slider(
              value: maxRank.value?.toDouble() ?? 1001.0,
              onChanged: (v) => setState(() {
                maxRank.value = v.toInt();
                if (maxRank.value! > 1000) maxRank.value = null;
              }),
              min: 10,
              max: 1001,
              //label: maxRank.value?.toString() ?? "All",
              //divisions: 10
            )),
            Text("All"),
          ]),
          Text(
              maxRank.value == null
                  ? "Show all names from the:"
                  : "Only show the top ${maxRank.value} most popular names from the:",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.left),
        ]));
  }
}

class _DecadeCheckboxes extends StatefulWidget {
  final HashSet<int> decades;
  _DecadeCheckboxes(this.decades);

  @override
  _FirstLetterCheckboxesState createState() =>
      _FirstLetterCheckboxesState(decades);
}

class _FirstLetterCheckboxesState extends State<_DecadeCheckboxes> {
  HashSet<int> decades;
  _FirstLetterCheckboxesState(this.decades);

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: List<int>.generate(201 - 188 + 1, (i) => i + 188)
            .map((d) => CheckboxListTile(
                title: Text((d * 10).toString() + "s"),
                value: decades.contains(d),
                onChanged: (bool? v) => setState(
                    () => v != null && v ? decades.add(d) : decades.remove(d))))
            .toList());
  }
}
