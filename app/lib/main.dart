import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/blocs/sharing/sharing.dart';
import 'package:nomdebebe/providers/names_provider.dart';
import 'package:nomdebebe/repositories/names_repository.dart';
import 'package:nomdebebe/repositories/settings_repository.dart';
import 'package:nomdebebe/repositories/shared_repository.dart';
import 'package:nomdebebe/screens/undecided_screen.dart';
import 'package:nomdebebe/screens/liked_screen.dart';
import 'package:nomdebebe/screens/sharing_screen.dart';
import 'package:nomdebebe/screens/settings_screen.dart';
import 'package:nomdebebe/screens/disliked_screen.dart';
import 'package:nomdebebe/screens/explore_screen.dart';
//import 'package:nomdebebe/blocs/debug_logger.dart';
import 'themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Bloc.observer = DebugLogger();
  NamesRepository names = NamesRepository(await NamesProvider.load());
  SettingsRepository settings = await SettingsRepository.load();
  SharedRepository shared = await SharedRepository.load();

  runApp(MultiBlocProvider(providers: [
    BlocProvider<SettingsBloc>(
        create: (BuildContext _) =>
            SettingsBloc(settings)..add(SettingsLoad())),
    BlocProvider<NamesBloc>(
        create: (BuildContext c) =>
            NamesBloc.load(names, BlocProvider.of<SettingsBloc>(c))
        //..add(NamesLoad()) // load the names only after we've loaded the settings
        // otherwise our initial screen will swap names if the settings change
        // the available names
        ),
    BlocProvider<SharingBloc>(
        create: (BuildContext c) =>
            SharingBloc(shared)..add(SharingEventRefresh())),
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
        title: "Nom de Bébé",
        theme: themeForType(settings.theme) ??
            (brightness == Brightness.dark ? darkTheme : lightTheme),
        home: ScreenContainer(),
      );
    });
  }
}

class ScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScreenContainerState();
}

class ScreenContainerState extends State<ScreenContainer>
    with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
          key: navigatorKey,
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
              case 'explore':
                builder = (BuildContext _) => ExploreScreen();
                break;
              case 'sharing':
                builder = (BuildContext _) => SharingScreen();
                break;
              case 'settings':
                builder = (BuildContext _) => SettingsScreen();
                break;
              case 'disliked':
                builder = (BuildContext _) => DislikedScreen();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> primary,
                        Animation<double> secondary) =>
                    builder(context),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                            opacity: Tween(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut)),
                            child: FadeTransition(
                                opacity: Tween(begin: 1.0, end: 0.0).animate(
                                    CurvedAnimation(
                                        parent: secondaryAnimation,
                                        curve: Curves.easeInOut)),
                                child: child)),
                settings: settings);
          }),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.headline3!.color,
        onTap: (idx) {
          switch (idx) {
            case 0:
              navigatorKey.currentState?.pushNamed('undecided');
              break;
            case 1:
              navigatorKey.currentState?.pushNamed('liked');
              break;
            case 2:
              navigatorKey.currentState?.pushNamed('explore');
              break;
            case 3:
              // upload our liked names whenever we navigate to that screen
              // TODO: when else to upload without wasting bandwidth?
              SharingBloc bloc = BlocProvider.of<SharingBloc>(context);
              bloc.add(SharingEventUpdateLikedNames(
                  BlocProvider.of<NamesBloc>(context).state.likedNames));

              navigatorKey.currentState?.pushNamed('sharing');
              break;
            case 4:
              navigatorKey.currentState?.pushNamed('settings');
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
              icon: Icon(FontAwesomeIcons.solidCompass), label: "Explore"),
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
