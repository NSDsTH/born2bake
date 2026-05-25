import 'package:born2bake/models/product.dart';
import 'package:born2bake/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CartProvider cart;

  Product makeProduct({String id = 'p1', double price = 100.0}) => Product(
        id: id,
        name: 'Test Product $id',
        description: 'desc',
        price: price,
        originalPrice: price * 1.2,
        categoryId: 'cat1',
        imageUrl: 'assets/images/test.png',
      );

  setUp(() {
    cart = CartProvider();
  });

  // ─── TC-U-CART-01: addItem ─────────────────────────────────────────────────

  group('TC-U-CART-01: addItem — เพิ่มสินค้าลงตะกร้า', () {
    test('เพิ่มสินค้าใหม่ในตะกร้าว่าง', () {
      cart.addItem(makeProduct(), 1, '100%', []);
      expect(cart.itemCount, equals(1));
    });

    test('สินค้าเดิม + sweetness เดิม → เพิ่ม quantity ไม่เพิ่ม itemCount', () {
      cart.addItem(makeProduct(), 1, '50%', []);
      cart.addItem(makeProduct(), 2, '50%', []);
      expect(cart.itemCount, equals(1));
      expect(cart.items.values.first.quantity, equals(3));
    });

    test('สินค้าเดิมแต่ต่าง sweetness → เพิ่ม entry แยก', () {
      cart.addItem(makeProduct(), 1, '0%', []);
      cart.addItem(makeProduct(), 1, '100%', []);
      expect(cart.itemCount, equals(2));
    });

    test('สินค้าเดิมแต่ต่าง addOns → เพิ่ม entry แยก', () {
      cart.addItem(makeProduct(), 1, '50%', []);
      cart.addItem(makeProduct(), 1, '50%', [
        {'name': 'Pearl', 'price': 10.0}
      ]);
      expect(cart.itemCount, equals(2));
    });
  });

  // ─── TC-U-CART-02: totalAmount ────────────────────────────────────────────

  group('TC-U-CART-02: totalAmount — คำนวณยอดรวม', () {
    test('คำนวณถูกต้องเมื่อไม่มี addOns', () {
      cart.addItem(makeProduct(price: 100.0), 2, '100%', []);
      expect(cart.totalAmount, equals(200.0));
    });

    test('รวม addOns price เข้าในยอดด้วย', () {
      final addOns = [
        {'name': 'Pearl', 'price': 15.0}
      ];
      cart.addItem(makeProduct(price: 80.0), 1, '50%', addOns);
      expect(cart.totalAmount, equals(95.0));
    });

    test('รวมหลายรายการได้ถูกต้อง', () {
      cart.addItem(makeProduct(id: 'p1', price: 50.0), 2, '100%', []);
      cart.addItem(makeProduct(id: 'p2', price: 80.0), 1, '0%', []);
      expect(cart.totalAmount, equals(180.0));
    });

    test('totalAmount เป็น 0 เมื่อตะกร้าว่าง', () {
      expect(cart.totalAmount, equals(0.0));
    });
  });

  // ─── TC-U-CART-03: incrementQuantity ─────────────────────────────────────

  group('TC-U-CART-03: incrementQuantity — เพิ่มจำนวน', () {
    test('เพิ่ม quantity ของ item ที่มีอยู่', () {
      cart.addItem(makeProduct(), 1, '100%', []);
      final key = cart.items.keys.first;
      cart.incrementQuantity(key);
      expect(cart.items[key]!.quantity, equals(2));
    });

    test('ไม่มีผลเมื่อ key ไม่มีอยู่', () {
      cart.incrementQuantity('nonexistent-key');
      expect(cart.itemCount, equals(0));
    });
  });

  // ─── TC-U-CART-04: decrementQuantity ─────────────────────────────────────

  group('TC-U-CART-04: decrementQuantity — ลดจำนวน', () {
    test('ลด quantity เมื่อ quantity > 1', () {
      cart.addItem(makeProduct(), 2, '100%', []);
      final key = cart.items.keys.first;
      cart.decrementQuantity(key);
      expect(cart.items[key]!.quantity, equals(1));
    });

    test('ลบ item ออกเมื่อ quantity ลดจาก 1 → 0', () {
      cart.addItem(makeProduct(), 1, '100%', []);
      final key = cart.items.keys.first;
      cart.decrementQuantity(key);
      expect(cart.itemCount, equals(0));
    });

    test('ไม่มีผลเมื่อ key ไม่มีอยู่', () {
      cart.decrementQuantity('nonexistent-key');
      expect(cart.itemCount, equals(0));
    });
  });

  // ─── TC-U-CART-05: removeItem ────────────────────────────────────────────

  group('TC-U-CART-05: removeItem — ลบรายการ', () {
    test('ลบ item ที่ระบุออกจากตะกร้า', () {
      cart.addItem(makeProduct(id: 'p1'), 1, '100%', []);
      cart.addItem(makeProduct(id: 'p2'), 1, '100%', []);
      final firstKey = cart.items.keys.first;
      cart.removeItem(firstKey);
      expect(cart.itemCount, equals(1));
    });

    test('ลบ item เดียวออก ตะกร้าว่าง', () {
      cart.addItem(makeProduct(), 1, '100%', []);
      final key = cart.items.keys.first;
      cart.removeItem(key);
      expect(cart.itemCount, equals(0));
      expect(cart.totalAmount, equals(0.0));
    });
  });

  // ─── TC-U-CART-06: clear ────────────────────────────────────────────────

  group('TC-U-CART-06: clear — ล้างตะกร้า', () {
    test('clear ล้างทุก item ออก', () {
      cart.addItem(makeProduct(id: 'p1'), 1, '100%', []);
      cart.addItem(makeProduct(id: 'p2'), 2, '50%', []);
      cart.clear();
      expect(cart.itemCount, equals(0));
      expect(cart.totalAmount, equals(0.0));
    });

    test('clear บนตะกร้าว่างไม่เกิด error', () {
      expect(() => cart.clear(), returnsNormally);
    });
  });
}
