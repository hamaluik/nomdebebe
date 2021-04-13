import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/blocs/settings/settings.dart';
import 'package:namekit/providers/names_provider.dart';
import 'package:namekit/repositories/names_repository.dart';
import 'package:namekit/repositories/settings_repository.dart';
import 'package:namekit/screens/undecided_screen.dart';
import 'package:namekit/screens/liked_screen.dart';
import 'package:namekit/screens/settings_screen.dart';
import 'package:namekit/blocs/debug_logger.dart';
import 'themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = DebugLogger();
  NamesRepository names = NamesRepository(await NamesProvider.load());
  SettingsRepository settings = await SettingsRepository.load();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<SettingsBloc>(
        create: (BuildContext _) =>
            SettingsBloc(settings)..add(SettingsLoad())),
    BlocProvider<NamesBloc>(
        create: (BuildContext c) =>
            NamesBloc.load(names, BlocProvider.of<SettingsBloc>(c))
              ..add(NamesLoad())),
  ], child: NamesApp()));
}

class NamesApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NamesAppState();
}

class NamesAppState extends State<NamesApp> with WidgetsBindingObserver {
  Brightness brightness = PlatformDispatcher.instance.platformBrightness;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    print("platform brightness changed: " +
        (WidgetsBinding.instance?.window.platformBrightness.toString() ?? "?"));
    setState(() => brightness =
        WidgetsBinding.instance?.window.platformBrightness ?? this.brightness);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settings) {
      return MaterialApp(
        title: "Namekit",
        theme: themeForType(settings.theme) ??
            (brightness == Brightness.dark ? darkTheme : lightTheme),
        home: ScreenContainer(),
      );
    });
  }
}

class ScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScreenContainerState();
}

class _ScreenContainerState extends State<ScreenContainer>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
          key: _navigatorKey,
          initialRoute: 'undecided',
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'undecided':
                builder = (BuildContext _) => UndecidedScreen();
                break;
              case 'liked':
                builder = (BuildContext _) => LikedScreen();
                break;
              case 'sharing':
                builder = (BuildContext _) => Container();
                break;
              case 'settings':
                builder = (BuildContext _) => SettingsScreen();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute(builder: builder, settings: settings);
          }),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.headline3!.color,
        onTap: (idx) {
          switch (idx) {
            case 0:
              _navigatorKey.currentState?.pushNamed('undecided');
              break;
            case 1:
              _navigatorKey.currentState?.pushNamed('liked');
              break;
            case 2:
              _navigatorKey.currentState?.pushNamed('sharing');
              break;
            case 3:
              _navigatorKey.currentState?.pushNamed('settings');
              break;
          }
          setState(() {
            currentIndex = idx;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.question), label: "Undecided"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidHeart), label: "Liked"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.child), label: "Sharing"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.wrench), label: "Settings"),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
