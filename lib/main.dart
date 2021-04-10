import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namekit/blocs/names/names.dart';
import 'package:namekit/providers/names_provider.dart';
import 'package:namekit/repositories/names_repository.dart';
import 'package:namekit/screens/undecided_screen.dart';
import 'package:namekit/screens/liked_screen.dart';
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
      home: ScreenContainer(),
    );
  }
}

class ScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScreenContainerState();
}

class _ScreenContainerState extends State<ScreenContainer> {
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
              case 'disliked':
                builder = (BuildContext _) => Container();
                break;
              case 'settings':
                builder = (BuildContext _) => Container();
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
              _navigatorKey.currentState?.pushNamed('disliked');
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
              icon: Icon(FontAwesomeIcons.heart), label: "Liked"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.thumbsDown), label: "Disliked"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.cogs), label: "Settings"),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
