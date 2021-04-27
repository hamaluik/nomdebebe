import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:nomdebebe/widgets/name_tile_link.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExploreScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController controller = TextEditingController();
  List<Name> names = [];
  String filter = "";
  List<Name> filteredNames = [];

  @override
  void initState() {
    super.initState();
    NamesRepository repo = BlocProvider.of<NamesBloc>(context).namesRepository;
    repo.getNames(count: 200000).then((List<Name> _names) => setState(() {
          names = _names;
          filteredNames = names;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
      return BlocBuilder<NamesBloc, NamesState>(
          builder: (BuildContext context, NamesState namesState) {
        if (names.length == 0) {
          return Center(child: SpinKitPumpingHeart(color: Colors.white));
        }

        return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  child: filteredNames.isEmpty
                      ? Center(
                          child: Icon(FontAwesomeIcons.baby,
                              color: Colors.white, size: 64))
                      : ListView.builder(
                          itemCount: filteredNames.length,
                          itemBuilder: (BuildContext context, int index) {
                            Name name = filteredNames[index];

                            return Hero(
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
                          filter = "";
                          filteredNames = names;
                        });
                      } else {
                        setState(() {
                          filter = search.trim();
                          filteredNames = names
                              .where((n) => n.name
                                  .toUpperCase()
                                  .contains(filter.toUpperCase()))
                              .toList();
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
