import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/widgets/name_card.dart';

class UndecidedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      int decidedCount = state.namesCount - state.undecidedNamesCount;
      String decided = decidedCount.toString();
      if (decided.length > 3) {
        decided = decided.substring(0, 1) + "," + decided.substring(1);
      }
      String undecided = state.undecidedNamesCount.toString();
      if (undecided.length > 3) {
        undecided = undecided.substring(0, 1) + "," + undecided.substring(1);
      }

      return Column(
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
          ]);
    });
  }
}
