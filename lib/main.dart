import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/my_collection/my_collection.dart';
import 'package:pokecard_tcg/pokedex/pokedex.dart';
import 'package:pokecard_tcg/search/search.dart';
import 'package:pokecard_tcg/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:pokecard_tcg/main.i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

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
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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

  static List<Widget> _widgetOptions = <Widget>[
    PokedexPage(),
    SearchPage(),
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MyDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search'.i18n,
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
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

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
