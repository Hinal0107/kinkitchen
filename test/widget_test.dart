import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinkitchen/core/widgets/kinkitchen_logo.dart';

void main() {
  testWidgets('KinKitchenLogo renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KinKitchenLogo(
            showText: true,
            subtitle: 'Fresh food, delivered fast to your door.',
          ),
        ),
      ),
    );

    expect(find.byType(KinKitchenLogo), findsOneWidget);
    expect(find.text('Fresh food, delivered fast to your door.'), findsOneWidget);
  });
}
