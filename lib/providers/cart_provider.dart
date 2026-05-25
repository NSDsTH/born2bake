import 'package:flutter/material.dart';
import 'package:born2bake/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final String sweetness;
  final List<Map<String, dynamic>> addOns;
  final double itemTotalPrice;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.sweetness,
    required this.addOns,
    required this.itemTotalPrice,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.itemTotalPrice * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, int quantity, String sweetness, List<Map<String, dynamic>> addOns) {
    double addonsPrice = addOns.fold(0, (sum, item) => sum + item['price']);
    double pricePerItem = product.price + addonsPrice;
    String cartItemId = '${product.id}-$sweetness-${addOns.map((e) => e['name']).join('-')}';

    if (_items.containsKey(cartItemId)) {
      _items.update(
        cartItemId,
        (existingItem) => CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          sweetness: existingItem.sweetness,
          addOns: existingItem.addOns,
          itemTotalPrice: existingItem.itemTotalPrice,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartItemId,
        () => CartItem(
          id: cartItemId,
          product: product,
          quantity: quantity,
          sweetness: sweetness,
          addOns: addOns,
          itemTotalPrice: pricePerItem,
        ),
      );
    }
    notifyListeners();
  }

  // ฟังก์ชันเพิ่มจำนวนสินค้าในตะกร้า
  void incrementQuantity(String cartItemId) {
    if (_items.containsKey(cartItemId)) {
      _items.update(
        cartItemId,
        (existingItem) => CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
          sweetness: existingItem.sweetness,
          addOns: existingItem.addOns,
          itemTotalPrice: existingItem.itemTotalPrice,
        ),
      );
      notifyListeners();
    }
  }

  // ฟังก์ชันลดจำนวนสินค้าในตะกร้า (ถ้าเหลือ 0 ให้ลบออก)
  void decrementQuantity(String cartItemId) {
    if (_items.containsKey(cartItemId)) {
      if (_items[cartItemId]!.quantity > 1) {
        _items.update(
          cartItemId,
          (existingItem) => CartItem(
            id: existingItem.id,
            product: existingItem.product,
            quantity: existingItem.quantity - 1,
            sweetness: existingItem.sweetness,
            addOns: existingItem.addOns,
            itemTotalPrice: existingItem.itemTotalPrice,
          ),
        );
      } else {
        _items.remove(cartItemId);
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.remove(cartItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}