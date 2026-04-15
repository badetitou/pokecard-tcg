import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
// import 'package:i18n_extension/i18n_extension.dart';
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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';

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
  const MyApp({super.key});

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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _debounce;
  int _selectedIndex = 0;
  String _query = '';
  int? minGridSize;
  int _pokedexRefreshVersion = 0;
  int _myCollectionRefreshVersion = 0;

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

  void _refreshPokedexAfterRestore() {
    setState(() {
      _pokedexRefreshVersion++;
      _myCollectionRefreshVersion++;
      _selectedIndex = 0;
    });
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
      return SearchResultsGridView(_query,
          padding: const EdgeInsets.only(top: 55), minGridSize: minGridSize!);
    }

    if (_selectedIndex == 0) {
      return PokedexPage(key: ValueKey(_pokedexRefreshVersion));
    }
    return MyCollectionPage(key: ValueKey(_myCollectionRefreshVersion));
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
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
              if (mounted) {
                initGridSize();
              }
            },
          ),
        ],
      ),
      drawer: MyDrawer(
        context,
        onSettingsUpdated: initGridSize,
        onPokedexRestoreCompleted: _refreshPokedexAfterRestore,
      ),
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
  static const String _driveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';
  static bool _googleSignInInitialized = false;
  static GoogleSignInAccount? _cachedGoogleAccount;

  late Database database;

  BuildContext originContext;
  final VoidCallback onSettingsUpdated;
  final VoidCallback onPokedexRestoreCompleted;

  MyDrawer(this.originContext,
      {required this.onSettingsUpdated,
      required this.onPokedexRestoreCompleted,
      super.key});

  @override
  Widget build(BuildContext context) {
    database = context.read<Database>();

    return Drawer(
      child: ListView(
        children: [
          ListTile(
              title: Text('Backup Pokédex'.i18n),
              onTap: () async {
                Navigator.of(context).pop();
                await _save(originContext);
              }),
          ListTile(
              title: Text('Restore Pokédex'.i18n),
              onTap: () async {
                Navigator.of(context).pop();
                await _restore(originContext);
              }),
          ListTile(
              title: Text('Disconnect Google'.i18n),
              onTap: () async {
                Navigator.of(context).pop();
                await _disconnectGoogle(originContext);
              }),
          ListTile(
              title: Text('Settings'),
              onTap: () async {
                await _navPush(originContext, SettingsPage());
                onSettingsUpdated();
              }),
        ],
      ),
    );
  }

  Future<dynamic> _navPush(BuildContext context, Widget page) {
    return Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child);
      },
    ));
  }

  Future<GoogleSignInAccount?> _connectToGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleSignInInitialized = true;
      }

      if (_cachedGoogleAccount != null) {
        return _cachedGoogleAccount;
      }

      final lightweightAuth =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      final lightweightAccount =
          lightweightAuth == null ? null : await lightweightAuth;

      final account = lightweightAccount ??
          await GoogleSignIn.instance
              .authenticate(scopeHint: [_driveAppDataScope]);
      _cachedGoogleAccount = account;
      print("User account: ${account.email}");
      return account;
    } catch (e) {
      print("Erreur d'authentification Google: $e");
      return null;
    }
  }

  Future<void> _showStatusPopup(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
  }) async {
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK'.i18n),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _connectToGoogle();
      if (account == null) {
        return;
      }

      drive.DriveApi driveApi = await configureDriveApi(account);
      final cardCount = (await database.allCardEntries).length;

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

      await _showStatusPopup(
        context,
        title: 'Backup complete'.i18n,
        message: '${'Saved cards'.i18n}: $cardCount',
      );
    } catch (error) {
      await _showStatusPopup(
        context,
        title: 'Error'.i18n,
        message: '${'An error occurred'.i18n}: $error',
        isError: true,
      );
    }
  }

  Future<drive.DriveApi> configureDriveApi(GoogleSignInAccount account) async {
    final authHeaders = await account.authorizationClient.authorizationHeaders(
          [_driveAppDataScope],
          promptIfNecessary: false,
        ) ??
        await account.authorizationClient.authorizationHeaders(
          [_driveAppDataScope],
          promptIfNecessary: true,
        );
    if (authHeaders == null) {
      throw Exception(
          'Impossible d\'obtenir un token Drive. Vérifiez les permissions Google Drive.');
    }

    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    return driveApi;
  }

  Future<void> _disconnectGoogle(BuildContext context) async {
    try {
      if (_googleSignInInitialized) {
        await GoogleSignIn.instance.disconnect();
      }
      _cachedGoogleAccount = null;

      await _showStatusPopup(
        context,
        title: 'Disconnected'.i18n,
        message: 'Google account disconnected'.i18n,
      );
    } catch (error) {
      await _showStatusPopup(
        context,
        title: 'Error'.i18n,
        message: '${'An error occurred'.i18n}: $error',
        isError: true,
      );
    }
  }

  Future<void> _restore(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _connectToGoogle();
      if (account == null) {
        return;
      }

      drive.DriveApi driveApi = await configureDriveApi(account);

      drive.FileList fileList = await driveApi.files
          .list(spaces: "appDataFolder", q: "name contains 'db.sqlite'");
      if (fileList.files == null || fileList.files!.isEmpty) {
        await _showStatusPopup(
          context,
          title: 'Error'.i18n,
          message: 'No backup found'.i18n,
          isError: true,
        );
        return;
      }

      print(fileList.files?.first.name);
      final dataDir = await paths.getApplicationDocumentsDirectory();
      final restoredDbFile = File(p.join(dataDir.path, 'db.restore.sqlite'));
      drive.Media response = await driveApi.files.get(fileList.files!.first.id!,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final dataStore = await response.stream.expand((chunk) => chunk).toList();
      await restoredDbFile.writeAsBytes(dataStore, flush: true);

      final restoredDatabase = Database(NativeDatabase(restoredDbFile));
      final restoredCards = await restoredDatabase.allCardEntries;
      final restoredCount = restoredCards.length;

      await database.transaction(() async {
        await database.delete(database.myCards).go();
        for (final card in restoredCards) {
          await database.into(database.myCards).insert(
                MyCardsCompanion.insert(
                  name: card.name,
                  language: card.language,
                  etat: card.etat,
                  cardType: card.cardType,
                  cardID: card.cardID,
                  nationalPokedexNumbers: Value(card.nationalPokedexNumbers),
                ),
              );
        }
      });

      await restoredDatabase.close();
      if (await restoredDbFile.exists()) {
        await restoredDbFile.delete();
      }

      onPokedexRestoreCompleted();

      await _showStatusPopup(
        context,
        title: 'Restore complete'.i18n,
        message: '${'Restored cards'.i18n}: $restoredCount',
      );
    } catch (error) {
      await _showStatusPopup(
        context,
        title: 'Error'.i18n,
        message: '${'An error occurred'.i18n}: $error',
        isError: true,
      );
    }
  }
}
