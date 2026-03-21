import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';


class MockHttpClient extends Mock implements HttpClient {}

void main() {
  testWidgets('CachedNetworkImage affiche le placeholder puis l\'erreur', (WidgetTester tester) async {
    // Remplace le HttpClient global par un mock qui simule une erreur
    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImage(
              imageUrl: 'https://invalid.url/image.png',
              placeholder: (context, url) => const Text('loading'),
              errorWidget: (context, url, error) => const Text('error'),
            ),
          ),
        ),
      );
      // Le placeholder doit s'afficher d'abord
      expect(find.text('loading'), findsOneWidget);
      // Simule le chargement de l'image
      await tester.pump(const Duration(seconds: 2));
      // L'erreur doit s'afficher (URL invalide ou mockée)
      expect(find.text('error'), findsOneWidget);
    }, createHttpClient: (context) => MockHttpClient());
  });
}
