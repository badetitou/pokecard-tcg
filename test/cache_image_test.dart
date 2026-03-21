import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CachedNetworkImage shows placeholder while loading',
      (WidgetTester tester) async {
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

    expect(find.text('loading'), findsOneWidget);
  });
}
