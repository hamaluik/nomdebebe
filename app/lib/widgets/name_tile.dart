import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameTile extends StatefulWidget {
  final Name name;
  final Widget? child;

  const NameTile(this.name, {Key? key, this.child}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _NameTileState();
}

// TODO: make this animate opening and closing
class _NameTileState extends State<NameTile> {
  bool _isExpanded = false;

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (BuildContext context, SettingsState settingsState) {
        return Padding(
            padding: EdgeInsets.all(2),
            child: Card(
                color: sexToColour(
                    context, widget.name.sex, settingsState.pinkAndBlue),
                elevation: 2,
                child: InkWell(
                    onTap: widget.child == null ? null : _handleTap,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(widget.name.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center)),
                      ClipRect(
                          child: Align(
                              alignment: Alignment.center,
                              heightFactor: _isExpanded ? 1.0 : 0.0,
                              child: Column(children: [
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Divider(height: 2, thickness: 2)),
                                widget.child ?? Container()
                              ]))),
                    ]))));
      });
    });
  }
}
