import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:nomdebebe/widgets/name_tile_link.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController controller = TextEditingController();
  SearchFilter? filter;
  final HashMap<int, Name> cachedNames = HashMap();

  static int _min(int a, int b) {
    return a < b ? a : b;
  }

  //static int _max(int a, int b) {
  //return a > b ? a : b;
  //}

  Name? getName(NamesRepository namesRepository, int index) {
    if (cachedNames.containsKey(index)) return cachedNames[index]!;

    int minIndex = cachedNames.keys.fold(0, _min);
    //int maxIndex = cachedNames.keys.fold(0, _max);

    if (index < minIndex) {
      // scrolling back
      List<Name> nameBatch = namesRepository.getNames(
          filters: filter == null ? [] : [filter!],
          skip: _min(index - 100, 0),
          count: 100);
      for (int i = 0; i < nameBatch.length; i++)
        cachedNames[_min(index - 100, 0) + i] = nameBatch[i];
    } else {
      // scrolling forward
      List<Name> nameBatch = namesRepository.getNames(
          filters: filter == null ? [] : [filter!], skip: index, count: 100);
      for (int i = 0; i < nameBatch.length; i++)
        cachedNames[index + i] = nameBatch[i];
    }
    // TODO: remove old names if the cache grows too large?
    return cachedNames[index];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        NamesRepository repo =
            BlocProvider.of<NamesBloc>(context).namesRepository;

        int nameCount =
            repo.countTotalNames(filters: filter == null ? [] : [filter!]);

        return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: nameCount,
                      itemBuilder: (BuildContext context, int index) {
                        Name? name = getName(repo, index);
                        return name == null
                            ? Container()
                            : Hero(
                                tag: "nameDetailsHero_" + name.id.toString(),
                                child: NameTileLink(
                                  name,
                                  onTap: (Name name) => Navigator.of(context)
                                      .push(MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              NameDetailsScreen(name))),
                                  key: Key(
                                      "__name_explorer_" + name.id.toString()),
                                ));
                      })),
              Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                    onChanged: (String search) {
                      if (search.trim().length < 2) {
                        setState(() {
                          filter = null;
                          cachedNames.clear();
                        });
                      } else {
                        setState(() {
                          filter = SearchFilter(search.trim());
                          cachedNames.clear();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      icon: Icon(FontAwesomeIcons.search),
                    ),
                  )),
            ]);
      });
    });
  }
}
