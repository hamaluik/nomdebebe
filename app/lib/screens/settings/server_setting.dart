import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/keys.dart';

class ServerSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListTile(
          key: Keys.settingsServer,
          title: Text("Server"),
          subtitle: Text(state.server),
          trailing: Icon(FontAwesomeIcons.chevronRight),
          leading: Icon(FontAwesomeIcons.server),
          onTap: () async {
            String? newServer = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                      child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: _ServerEditor(),
                  ));
                });
            if (newServer != null)
              BlocProvider.of<SettingsBloc>(context)
                  .add(SettingsSetServer(newServer.trim()));
          });
    });
  }
}

class _ServerEditor extends StatefulWidget {
  _ServerEditor();

  @override
  _ServerEditorState createState() => _ServerEditorState();
}

class _ServerEditorState extends State<_ServerEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: BlocProvider.of<SettingsBloc>(context).state.server);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
                    Navigator.pop(context, _controller.value);
                  },
                  child: Text("SAVE"))
            ]),
      ),
      Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://my.name.server'),
            controller: _controller,
            onSubmitted: (String value) => Navigator.pop(context, value),
          )),
    ]);
  }
}
