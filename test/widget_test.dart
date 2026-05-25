import 'package:born2bake/models/product.dart';
import 'package:born2bake/providers/cart_provider.dart';
import 'package:born2bake/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('TC-W01: Empty Cart Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(home: CartScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ไม่มีสินค้าในตะกร้า'), findsOneWidget);
    expect(find.text('ล้างตะกร้า'), findsOneWidget);
  });

  testWidgets('TC-W02: Cart Screen renders product item and removes it when delete icon tapped', (WidgetTester tester) async {
    final cartProvider = CartProvider();
    final product = Product(
      id: 'test_product',
      name: 'Test Bakery Item',
      description: 'Test description',
      price: 99.0,
      originalPrice: 120.0,
      categoryId: 'c1',
      imageUrl: 'assets/images/test.png',
    );

    cartProvider.addItem(product, 1, '100%', []);

    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>.value(
        value: cartProvider,
        child: const MaterialApp(home: CartScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Bakery Item'), findsOneWidget);
    expect(find.byKey(const Key('delete-test_product-100%-')), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-test_product-100%-')));
    await tester.pumpAndSettle();

    expect(find.text('ไม่มีสินค้าในตะกร้า'), findsOneWidget);
  });
}
