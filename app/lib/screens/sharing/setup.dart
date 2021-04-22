import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';
import 'package:share/share.dart';
//import 'package:auto_size_text_field/auto_size_text_field.dart';

class SetupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharingBloc, SharingState>(
        builder: (BuildContext context, SharingState sharingState) {
      if (sharingState.myID == null) {
        return Center(
            child: Text("Something went wrong sharing your liked names list",
                style: Theme.of(context).textTheme.caption));
      }

      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Share this code with your partner:",
                  style: Theme.of(context).textTheme.headline6),
              Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0,
                        color: Theme.of(context).textTheme.headline4?.color ??
                            Colors.black),
                  ),
                  child: TextButton(
                      onPressed: () async => Share.share(sharingState.myID!,
                          subject: "My sharing code on Nom de Bébé"),
                      child: Text(
                        sharingState.myID!,
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
                      ))),
              Text("And enter their code here:",
                  style: Theme.of(context).textTheme.headline6),
              Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0,
                        color: Theme.of(context).textTheme.headline4?.color ??
                            Colors.black),
                  ),
                  child: _CodeTextField(sharingState.partnerID)),
              sharingState.partnerNames.isEmpty
                  ? Text(
                      "It looks like your partner hasn't shared any favourite names yet!",
                      textAlign: TextAlign.center)
                  : Container(),
            ],
          ));
    });
  }
}

class _CodeTextField extends StatefulWidget {
  final String? initialCode;

  const _CodeTextField(this.initialCode);

  @override
  State<StatefulWidget> createState() => _CodeTextFieldState(this.initialCode);
}

class _CodeTextFieldState extends State<_CodeTextField> {
  final String? initialCode;
  TextEditingController? _controller;

  _CodeTextFieldState(this.initialCode);

  @override
  void initState() {
    super.initState();
    if (_controller != null) _controller?.dispose();
    _controller = TextEditingController(text: initialCode);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
            controller: _controller,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
            autocorrect: false,
            maxLines: 1,
            maxLength: widget.initialCode?.length ?? 12,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: "",
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (String code) => BlocProvider.of<SharingBloc>(context)
                .add(SharingEventSetPartnerID(code))));
  }
}
