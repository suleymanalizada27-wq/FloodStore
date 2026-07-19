import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flood_store/main.dart';
import 'package:flood_store/features/splash/presentation/splash_screen.dart';
import 'package:flood_store/core/router/app_router.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Just verify the app widget builds without throwing
    await tester.pumpWidget(const ProviderScope(child: FloodStoreApp()));
    
    // App should build
    expect(find.byType(FloodStoreApp), findsOneWidget);
  });

  testWidgets('SplashScreen calls onNavigate after delay', (WidgetTester tester) async {
    bool navigated = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SplashScreen(onNavigate: () => navigated = true),
        ),
      ),
    );
    
    expect(navigated, isFalse);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(navigated, isTrue);
  });
}