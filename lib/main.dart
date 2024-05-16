import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/my_collection/my_collection.dart';
import 'package:pokecard_tcg/pokedex/pokedex.dart';
import 'package:pokecard_tcg/search/search.dart';
import 'package:pokecard_tcg/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:pokecard_tcg/main.i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:shared_preferences/shared_preferences.dart';

import 'GoogleAuthClient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (context) => constructDb(),
      dispose: (context, db) => db.close(),
      child: MaterialApp(
        title: 'Pokécard TCG',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', "US"),
          const Locale('fr', "FR"),
        ],
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.brown,
            brightness: Brightness.dark,
            useMaterial3: true),
        home: I18n(child: MyHomePage(title: 'Pokécard TCG')),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title}) : super();

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final FloatingSearchBarController controller = FloatingSearchBarController();
  int? minGridSize;

  @override
  initState() {
    super.initState();
    initGridSize();
  }

  static List<Widget> _widgetOptions = <Widget>[
    PokedexPage(),
    MyCollectionPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      drawer: MyDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_to_photos_outlined),
            label: 'My Collection'.i18n,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: buildSearchBar(),
    );
  }

  Map<String, String> _existingCategory = {
    'name': 'name:',
    'id': 'id:',
    'supertype': 'supertype:',
    'subtypes': 'subtypes:',
    'hp': 'hp:',
    'types': 'types:',
    'attacks name': 'attacks.name:',
    'artist': 'artist:',
    'nationalPokedexNumbers': 'nationalPokedexNumbers:',
  };

  void initGridSize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      minGridSize = sharedPreferences.getInt('gridSize') ?? 3;
    });
  }

  Widget buildSearchBar() {
    final List<FloatingSearchBarAction> actions = <FloatingSearchBarAction>[
      FloatingSearchBarAction(
        showIfClosed: false,
        showIfOpened: true,
        child: CircularButton(
          icon: const Icon(Icons.help),
          onPressed: () {
            _showSearchHelper(context);
          },
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: true,
      ),
      FloatingSearchBarAction(
        showIfOpened: false,
        showIfClosed: _query != '',
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _query = '';
              controller.clear();
            });
          },
        ),
      )
    ];

    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
        automaticallyImplyBackButton: false,
        controller: controller,
        hint: 'Search... [name:bulba*]'.i18n,
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        iconColor: Colors.grey,
        transitionCurve: Curves.easeInOutCubic,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        openAxisAlignment: 0.0,
        actions: actions,
        title: _query != '' ? Text(_query) : Text('Pokecard TCG'),
        debounceDelay: const Duration(milliseconds: 500),
        // onKeyEvent: (KeyEvent keyEvent) {
        //   if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
        //     controller.query = '';
        //     controller.close();
        //   }
        // },
        transition: CircularFloatingSearchBarTransition(spacing: 16),
        onSubmitted: (query) {
          _search(query);
        },
        body: Container(
            child: Padding(
          padding: const EdgeInsets.only(top: 55),
          child: buildBody(),
        )),
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 4.0,
                child: Builder(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _existingCategory.entries
                          .map(
                            (term) => ListTile(
                              title: Text(
                                term.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                controller.query += term.value;
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                )),
          );
        });
  }

  String _query = '';

  _search(String text) {
    setState(() => _query = text);
    controller.close();
  }

  Widget buildBody() {
    if (minGridSize == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (_query != '') {
      return SearchResultsGridView(
        _query,
        padding: const EdgeInsets.only(top: 55),
        minGridSize: minGridSize!,
      );
    } else {
      return _widgetOptions.elementAt(_selectedIndex);
    }
  }

  void _showSearchHelper(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                  text: 'Request:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 3),
                )),
                Text.rich(TextSpan(
                  text: 'Keyword matching:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for all cards that have "charizard" in the name field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard',
                ),
                Text.rich(TextSpan(
                  text:
                      'Search for "charizard" in the name field AND the type "mega" in the subtypes field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard subtypes:mega',
                ),
                Text.rich(TextSpan(
                  text:
                      'Search for "charizard" in the name field AND either the subtypes of "mega" or "vmax":'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard (subtypes:mega OR subtypes:vmax)',
                ),
                Text.rich(TextSpan(
                  text: 'Wildcard Matching:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for any card that starts with "char" in the name field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:char*',
                ),
                Text.rich(TextSpan(
                  text: 'Range Searches:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for only cards that feature the original 151 pokemon:'
                          .i18n,
                )),
                CommandExample(text: 'nationalPokedexNumbers:[1 TO 151]'),
              ],
            ),
          );
        });
  }
}

class CommandExample extends StatelessWidget {
  final String text;

  const CommandExample({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12)),
        child: Text(text));
  }
}

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  late Database database;

  BuildContext originContext;

  MyDrawer(this.originContext);

  @override
  Widget build(BuildContext context) {
    this.database = context.read<Database>();

    return Drawer(
      child: ListView(
        children: [
          ListTile(
              title: Text('Backup Pokédex'.i18n), onTap: () => _save(context)),
          ListTile(
              title: Text('Restore Pokédex'.i18n),
              onTap: () => _restore(context)),
          ListTile(
              title: Text('Settings'),
              onTap: () => _navPush(originContext, SettingsPage())),
        ],
      ),
    );
  }

  Future<dynamic> _navPush(BuildContext context, Widget page) {
    return Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child);
      },
    ));
  }

  FutureOr<signIn.GoogleSignInAccount?> _connectToGoogle() async {
    final googleSignIn = signIn.GoogleSignIn.standard(
        scopes: [drive.DriveApi.driveAppdataScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");
    return account;
  }

  void _save(context) async {
    final signIn.GoogleSignInAccount? account = await _connectToGoogle();
    if (account != null) {
      drive.DriveApi driveApi = await configureDriveApi(account);

      final dataDir = await paths.getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dataDir.path, 'db.sqlite'));

      var media = new drive.Media(
          dbFile.openRead().asBroadcastStream(), await dbFile.length());
      var driveFile = new drive.File();
      driveFile.name = "db.sqlite";
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = ["appDataFolder"];

      final result = await driveApi.files.create(driveFile, uploadMedia: media);
      print("Upload result: $result");
      SnackBar backupSnack = SnackBar(
        content: Text('Backed up!'.i18n),
      );
      ScaffoldMessenger.of(context).showSnackBar(backupSnack);
    }
  }

  Future<drive.DriveApi> configureDriveApi(
      signIn.GoogleSignInAccount account) async {
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    return driveApi;
  }

  void _restore(context) async {
    final signIn.GoogleSignInAccount? account = await _connectToGoogle();
    if (account != null) {
      drive.DriveApi driveApi = await configureDriveApi(account);

      drive.FileList fileList = await driveApi.files
          .list(spaces: "appDataFolder", q: "name contains 'db.sqlite'");
      print(fileList.files?.first.name);
      await database.close();
      final dataDir = await paths.getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dataDir.path, 'db.sqlite'));
      await dbFile.delete();
      drive.Media response = await driveApi.files.get(fileList.files!.first.id!,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      List<int> dataStore = [];
      response.stream.listen((data) {
        print("DataReceived: ${data.length}");
        dataStore.insertAll(dataStore.length, data);
      }, onDone: () async {
        await dbFile.writeAsBytes(dataStore);
        print("Task Done");
      }, onError: (error) {
        print("Some Error");
      });
      SnackBar snackBar = SnackBar(
        content: Text('Restored!'.i18n),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
