import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:fl_chart/fl_chart.dart';

class NameDetailsScreen extends StatefulWidget {
  final Name name;
  const NameDetailsScreen(this.name);
  @override
  State<StatefulWidget> createState() => _NameDetailsScreenState();
}

class _NameDetailsScreenState extends State<NameDetailsScreen> {
  LinkedHashMap<int, int> popularityData = LinkedHashMap();
  LinkedHashMap<int, int> decadeCounts = LinkedHashMap();
  LineChartBarData? data;

  @override
  void initState() {
    super.initState();

    NamesRepository repo = BlocProvider.of<NamesBloc>(context).namesRepository;
    popularityData = repo.getNameDecadeCounts(widget.name.id);
    decadeCounts = repo.getDecadeCounts();

    data = LineChartBarData(
        isCurved: true,
        colors: [Colors.white],
        dotData: FlDotData(show: false),
        isStrokeCapRound: true,
        spots: popularityData.entries
            .map((e) => FlSpot(
                (e.key * 10).toDouble(),
                100.0 *
                    e.value.toDouble() /
                    (decadeCounts[e.key]?.toDouble() ?? 1.0)))
            .toList());

    print(data);
  }

  @override
  Widget build(BuildContext context) {
    NamesBloc namesBloc = BlocProvider.of<NamesBloc>(context);
    List<Widget> buttons = [];
    if (widget.name.like != null) {
      buttons.add(TextButton.icon(
        icon: Icon(FontAwesomeIcons.question, color: Colors.white),
        onPressed: () {
          namesBloc.add(NamesUndecide(widget.name));
          Navigator.of(context).pop();
        },
        label: Text("Undecide",
            style: Theme.of(context)
                .textTheme
                .button
                ?.copyWith(color: Colors.white)),
      ));
    }
    if (widget.name.like != false) {
      buttons.add(TextButton.icon(
        icon: Icon(FontAwesomeIcons.solidThumbsDown, color: Colors.white),
        onPressed: () {
          namesBloc.add(NamesDislike(widget.name));
          Navigator.of(context).pop();
        },
        label: Text("Dislike",
            style: Theme.of(context)
                .textTheme
                .button
                ?.copyWith(color: Colors.white)),
      ));
    }
    if (widget.name.like != true) {
      buttons.add(TextButton.icon(
        icon: Icon(FontAwesomeIcons.solidHeart, color: Colors.white),
        onPressed: () {
          namesBloc.add(NamesLike(widget.name));
          Navigator.of(context).pop();
        },
        label: Text("Like",
            style: Theme.of(context)
                .textTheme
                .button
                ?.copyWith(color: Colors.white)),
      ));
    }

    return SafeArea(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (BuildContext context, SettingsState settingsState) =>
                    Hero(
                        tag: "nameDetailsHero_" + widget.name.id.toString(),
                        child: Stack(children: [
                          Card(
                              color: sexToColour(context, widget.name.sex,
                                  settingsState.pinkAndBlue),
                              elevation: 2,
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(children: <Widget>[
                                    Text(widget.name.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(color: Colors.white),
                                        textAlign: TextAlign.center),
                                    Expanded(
                                        child: Center(
                                            child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child:
                                                        LineChart(LineChartData(
                                                      gridData: FlGridData(
                                                          show: false),
                                                      borderData: FlBorderData(
                                                          show: false,
                                                          border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .white,
                                                                width: 2.0),
                                                            //left: BorderSide(
                                                            //color: Colors.white,
                                                            //width: 2.0),
                                                          )),
                                                      axisTitleData:
                                                          FlAxisTitleData(
                                                        show: true,
                                                        bottomTitle: AxisTitle(
                                                            showTitle: true,
                                                            titleText: "Decade",
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        leftTitle: AxisTitle(
                                                            showTitle: true,
                                                            titleText:
                                                                "Popularity",
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles:
                                                            SideTitles(
                                                          getTextStyles: (_) =>
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                          showTitles: true,
                                                          reservedSize: 22,
                                                          getTitles: (value) {
                                                            switch (
                                                                value.toInt()) {
                                                              case 1880:
                                                                return "1880's";
                                                              case 1900:
                                                                return "1900's";
                                                              case 1920:
                                                                return "1920's";
                                                              case 1940:
                                                                return "1940's";
                                                              case 1960:
                                                                return "1960's";
                                                              case 1980:
                                                                return "1980's";
                                                              case 2000:
                                                                return "2000's";
                                                              case 2020:
                                                                return "2020's";
                                                              default:
                                                                return "";
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                            showTitles: false),
                                                      ),
                                                      lineTouchData:
                                                          LineTouchData(
                                                              enabled: false),
                                                      lineBarsData: data == null
                                                          ? []
                                                          : [data!],
                                                    )))))),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: buttons)
                                  ]))),
                          Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton(
                                icon: Icon(FontAwesomeIcons.times,
                                    color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              )),
                        ])))));
  }
}
