import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/widgets/name_card.dart';

class UndecidedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      int totalNames =
          BlocProvider.of<NamesBloc>(context).namesRepository.countTotalNames();
      int undecidedCount = BlocProvider.of<NamesBloc>(context)
          .namesRepository
          .countUndecidedNames();
      int decidedCount = totalNames - undecidedCount;
      String decided = decidedCount.toString();
      if (decided.length > 3) {
        decided = decided.substring(0, 1) + "," + decided.substring(1);
      }
      String undecided = undecidedCount.toString();
      if (undecided.length > 3) {
        undecided = undecided.substring(0, 1) + "," + undecided.substring(1);
      }

      print("next undecided: " + state.nextUndecidedName.toString());

      return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text("$decided done\n$undecided to go",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.center)))),
              Padding(
                  padding: EdgeInsets.all(32),
                  child: state.nextUndecidedName == null
                      ? Container()
                      : NameCard(state.nextUndecidedName!))
            ]),
        bottomNavigationBar:
            BottomNavigationBar(items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.question), label: "Undecided"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heart), label: "Liked"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.thumbsDown), label: "Disliked"),
        ], currentIndex: 0),
      );
    });
  }
}
