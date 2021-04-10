import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/providers/names_provider.dart';
import 'package:namekit/repositories/names_repository.dart';
import 'package:namekit/screens/undecided_screen.dart';
import 'themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NamesProvider provider = await NamesProvider.load();
  runApp(BlocProvider(
      create: (BuildContext context) {
        return NamesBloc(NamesRepository(provider))..add(NamesLoad());
      },
      child: NamesApp()));
}

class NamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Namekit",
        theme: lightTheme,
        initialRoute: "undecided",
        routes: {"undecided": (context) => UndecidedScreen()});
  }
}
