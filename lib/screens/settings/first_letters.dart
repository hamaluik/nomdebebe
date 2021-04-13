import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/keys.dart';

String _lettersDisplay(HashSet<String> letters) {
  if (letters.isEmpty) return "Any letter";

  List<String> lettersSorted = letters.toList();
  lettersSorted.sort();
  return lettersSorted.join(",");
}

class FirstLetterOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsFirstLetters,
          title: Text("Only names that begin with"),
          subtitle: Text(_lettersDisplay(state.firstLetters)),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.signature),
          onTap: () async {
            HashSet<String> _letters = HashSet.from(state.firstLetters);
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
                      Expanded(child: _FirstLetterCheckboxes(_letters)),
                    ]));
            if (save == true) {
              print("setting first letters to: " + _letters.join(","));
              BlocProvider.of<SettingsBloc>(context)
                  .add(SettingsSetFirstLetters(_letters));
            }
          });
    });
  }
}

class _FirstLetterCheckboxes extends StatefulWidget {
  final HashSet<String> letters;
  _FirstLetterCheckboxes(this.letters);

  @override
  _FirstLetterCheckboxesState createState() =>
      _FirstLetterCheckboxesState(letters);
}

class _FirstLetterCheckboxesState extends State<_FirstLetterCheckboxes> {
  HashSet<String> letters;
  _FirstLetterCheckboxesState(this.letters);

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .characters
            .map((l) => CheckboxListTile(
                title: Text(l),
                value: letters.contains(l),
                onChanged: (bool? v) => setState(
                    () => v != null && v ? letters.add(l) : letters.remove(l))))
            .toList());
  }
}
