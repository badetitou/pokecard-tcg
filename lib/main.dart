import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
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

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Database>(create: (_) => constructDb()),
      ],
      child: MaterialApp(
        title: 'Pokecard TCG',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    Timer? _debounce;
  int _selectedIndex = 0;
  String _query = '';
  int? minGridSize;
  final List<Widget> _widgetOptions = [
    PokedexPage(),
    MyCollectionPage(),
  ];

  @override
  void initState() {
    super.initState();
    initGridSize();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initGridSize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      minGridSize = sharedPreferences.getInt('gridSize') ?? 3;
    });
  }

  void _search(String text) {
    setState(() => _query = text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Widget buildBody() {
    if (minGridSize == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_query.isNotEmpty) {
      return SearchResultsGridView(_query, padding: const EdgeInsets.only(top: 55), minGridSize: minGridSize!);
    } else {
      return _widgetOptions.elementAt(_selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokecard TCG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_to_photos_outlined),
            label: 'My Collection',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search... [name:bulba*]'.i18n,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    controller: TextEditingController(text: _query),
                    onSubmitted: (query) {
                      _search(query);
                    },
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        _search(value);
                      });
                    },
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _query = '';
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Aide recherche',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Aide recherche'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Exemples de recherche :'),
                            CommandExample(text: 'name:bulba*'),
                            CommandExample(text: 'type:fire'),
                            CommandExample(text: 'hp>100'),
                            CommandExample(text: 'rarity:rare'),
                            SizedBox(height: 8),
                            Text('Vous pouvez combiner plusieurs filtres !'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(child: buildBody()),
        ],
      ),
    );
  }

}

class CommandExample extends StatelessWidget {
  final String text;

  const CommandExample({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
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

  MyDrawer(this.originContext, {super.key});

  @override
  Widget build(BuildContext context) {
    database = context.read<Database>();

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

  Future<signIn.GoogleSignInAccount?> _connectToGoogle() async {
    try {
      final googleSignIn = signIn.GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/drive.appdata',
          'https://www.googleapis.com/auth/drive.file',
        ],
      );
      final account = await googleSignIn.signIn();
      if (account != null) {
        print("User account: ${account.email}");
        return account;
      } else {
        print("L'utilisateur a annulé la connexion.");
        return null;
      }
    } catch (e) {
      print("Erreur d'authentification Google: $e");
      return null;
    }
  }

  void _save(context) async {
    final signIn.GoogleSignInAccount? account = await _connectToGoogle();
    if (account != null) {
      drive.DriveApi driveApi = await configureDriveApi(account);

      final dataDir = await paths.getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dataDir.path, 'db.sqlite'));

      var media = drive.Media(
          dbFile.openRead().asBroadcastStream(), await dbFile.length());
      var driveFile = drive.File();
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
    // Récupération du token d'accès via authorizationClient
    final authentication = await account.authentication;
    final accessToken = authentication.accessToken;
    if (accessToken == null) {
      throw Exception('Impossible de récupérer le token Google.');
    }
    final authHeaders = {
      'Authorization': 'Bearer $accessToken',
      'X-Goog-AuthUser': '0',
    };
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
