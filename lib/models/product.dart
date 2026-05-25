class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // แปลงข้อมูลจาก Firestore (Map) เป็น Category Object
  factory Category.fromMap(Map<String, dynamic> map, String documentId) {
    return Category(
      id: documentId,
      name: map['name'] ?? '',
    );
  }

  // แปลง Category Object กลับเป็น Map สำหรับอัปโหลดขึ้น Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String categoryId; // เปลี่ยนมารับเป็น categoryId แทนเพื่อให้อ้างอิงง่ายขึ้นใน Firestore
  final String imageUrl;
  final bool isOutOfStock;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.imageUrl,
    this.isOutOfStock = false,
  });

  // แปลงข้อมูลจาก Firestore (Map) เป็น Product Object
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      // ใช้ .toDouble() เพื่อป้องกัน Error กรณี Firestore ส่งค่ามาเป็น int
      price: (map['price'] ?? 0).toDouble(), 
      originalPrice: map['originalPrice'] != null ? (map['originalPrice']).toDouble() : null,
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isOutOfStock: map['isOutOfStock'] ?? false,
    );
  }

  // แปลง Product Object กลับเป็น Map สำหรับอัปโหลดขึ้น Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isOutOfStock': isOutOfStock,
    };
  }
}

// --- Mock Data ---

// 1. ข้อมูล Category
final List<Category> mockCategories = [
  Category(id: 'c1', name: 'Bakery'),
  Category(id: 'c2', name: 'Cake & Cookie'),
  Category(id: 'c3', name: 'Drink'),
  Category(id: 'c4', name: 'Mayongchid Serie'),
];

// 2. ข้อมูล Product พร้อม imageUrl สมมติ
final List<Product> mockProducts = [
  // หมวดหมู่: Bakery
  Product(
    id: 'p1',
    name: 'Shiopan Original',
    description: 'แป้งเหนียวนุ่ม ฐานกรอบ หอมเนย เค็มนัวพอดี // ทางร้านใส่ให้ถุงละ 1 ชิ้น...',
    price: 35.0,
    categoryId: mockCategories[0].id, // อัปเดตมาใช้ categoryId
    imageUrl: 'assets/images/shiopan_original.png',
  ),
  Product(
    id: 'p2',
    name: 'Pro Set Shiopan 3 ชิ้น',
    description: 'จัดเป็นถุงเซ็ตไว้ให้ 3 ชิ้น มีวิธีเก็บและวิธีอุ่นร้อนให้ค่ะ...',
    price: 100.0,
    categoryId: mockCategories[0].id,
    imageUrl: 'assets/images/shiopan_set.png',
  ),
  Product(
    id: 'p3',
    name: 'Redbean Butter Shiopan',
    description: 'ถั่วแดงหวานมัน ตัดกับเนยสดข้างบน เข้ากันได้ดีมากๆ ท้าให้ลอง (ร้านอุ่นให้ร้อนๆ ทุกออเดอร์ เนยอาจจะ...',
    price: 55.0,
    categoryId: mockCategories[0].id,
    imageUrl: 'assets/images/shiopan_redbean.png',
  ),
  Product(
    id: 'p4',
    name: 'Taro Butter Shiopan',
    description: 'รสชาติเผือกหวานหอมกะทิ ตัดกับเนยเค็ม เข้ากันมาก ใครสายหวาน สายเผือกต้องลองค่ะ (ร้านอุ่...',
    price: 59.0,
    categoryId: mockCategories[0].id,
    imageUrl: 'assets/images/shiopan_taro.png',
  ),

  // หมวดหมู่: Cake & Cookie
  Product(
    id: 'p5',
    name: 'เค้กไก่หยอง',
    description: 'เค้กไก่หยอง 1 กล่อง 3 ชิ้น เนื้อเค้กนุ่มๆ หอมมายองเนส ไก่หยองนำเข้าจากจีน รสชาติเข้มข้น',
    price: 70.0,
    categoryId: mockCategories[1].id,
    imageUrl: 'assets/images/cake_chicken.png',
  ),
  Product(
    id: 'p6',
    name: 'Brownie',
    description: 'สูตรไม่หน้าฟิล์มแต่เนื้อนุ่มหนึบ แช่เย็นยิ่งหนึบ กินกับนมอร่อยมากก',
    price: 50.0,
    categoryId: mockCategories[1].id,
    imageUrl: 'assets/images/brownie.png',
  ),

  // หมวดหมู่: Drink
  Product(
    id: 'p7',
    name: 'นมสดสตอเบอร์รี่',
    description: '1 ขวด นมสด กับแยมสตอเบอร์รี่ homemade รสชาติหวานน้อย มีความเปรี้ยวของสตอเบอร์รี่',
    price: 29.0,
    categoryId: mockCategories[2].id,
    imageUrl: 'assets/images/drink_strawberry.png',
  ),
  Product(
    id: 'p8',
    name: 'ชาไทย',
    description: 'ฉันจะกินชาไทยทุกวัน',
    price: 50.0,
    categoryId: mockCategories[2].id,
    imageUrl: 'assets/images/drink_thai_tea.png',
  ),

  // หมวดหมู่: Mayongchid Serie
  Product(
    id: 'p9',
    name: 'มะยงชิดชีสพาย',
    description: 'มะยงชิดสวนหลังบ้าน ออแกนิกปลอดสาร หวานอมเปรี้ยว ตัวครีมชีสดีที่สุด อร่อยที่สุด เบาไม่เลี่ยน...',
    price: 95.0,
    categoryId: mockCategories[3].id,
    imageUrl: 'assets/images/mayongchid_cheesepie.png',
    isOutOfStock: true,
  ),
  Product(
    id: 'p10',
    name: 'มะยงชิดคว้านเม็ด',
    description: 'มะยงชิดคว้านเม็ด พร้อมทาน รสชาติหวานอมเปรี้ยว น้ำหนัก 320-350 ต่อกล่อง (8 ชิ้น)',
    price: 100.0,
    categoryId: mockCategories[3].id,
    imageUrl: 'assets/images/mayongchid_deseeded.png',
    isOutOfStock: true,
  ),
];