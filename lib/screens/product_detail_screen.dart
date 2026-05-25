import 'package:flutter/material.dart';
import 'package:born2bake/models/product.dart';

import 'package:provider/provider.dart';
import 'package:born2bake/providers/cart_provider.dart';
import 'package:born2bake/screens/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ตัวแปรเก็บสถานะการเลือก
  int selectedSweetnessIndex = 3; // ค่าเริ่มต้นที่ 100%
  int quantity = 1;

  final Color primaryGreen = const Color(0xFF1F5C4D);
  final Color primaryRed = const Color(0xFFF04438);

  final List<Map<String, String>> sweetnessLevels = [
    {'label': 'ไม่หวาน', 'value': '0%'},
    {'label': 'หวานน้อย', 'value': '25%'},
    {'label': 'ปานกลาง', 'value': '50%'},
    {'label': 'หวานปกติ', 'value': '100%'},
  ];

  // ข้อมูลจำลองสำหรับ Topping
  final List<Map<String, dynamic>> addons = [
    {'name': 'เพิ่มหวานมัน', 'price': 10, 'image': 'assets/images/milk_1.png'},
    {'name': 'เพิ่มมัน', 'price': 10, 'image': 'assets/images/milk_2.png'},
    {'name': 'โอริโอ้ คุกกี้', 'price': 10, 'image': 'assets/images/oreo.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_basket, color: primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // เว้นที่ให้ BottomBar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนรูปภาพ
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle, // ทำพื้นหลังเป็นวงกลมตามภาพ
                ),
                child: Image.asset(
                  widget.product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 80, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. ชื่อสินค้า
            Center(
              child: Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. เลือกระดับความหวาน
            _buildSectionTitle('เลือกระดับความหวาน'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(sweetnessLevels.length, (index) {
                  final isSelected = selectedSweetnessIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSweetnessIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[200] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? primaryGreen : Colors.grey[200]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            sweetnessLevels[index]['value']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primaryGreen : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sweetnessLevels[index]['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? primaryGreen : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),

            // 4. เพิ่มพิเศษ (Add-ons)
            _buildSectionTitle('เพิ่มพิเศษ'),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: addons.length,
                itemBuilder: (context, index) {
                  final addon = addons[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              addon['image'],
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addon['name'],
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '฿${addon['price']}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // 5. Bottom Navigation Bar สำหรับเลือกจำนวนและปุ่มสั่งซื้อ
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('จำนวน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove, () {
                        if (quantity > 1) setState(() => quantity--);
                      }),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      _buildQuantityButton(Icons.add, () {
                        setState(() => quantity++);
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    // 1. ดึงข้อมูลที่เลือก
                    final selectedSweetness = sweetnessLevels[selectedSweetnessIndex]['label']!;
                    final List<Map<String, dynamic>> selectedAddOns = [];

                    // 2. เรียกใช้ Provider เพื่อ Add Item
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      widget.product,
                      quantity,
                      selectedSweetness,
                      selectedAddOns,
                    );

                    // 3. ปิดหน้า Detail และเปิดหน้า Cart แทนที่ทันที
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  child: const Text('สั่งซื้อ', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper สำหรับหัวข้อ
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget Helper สำหรับปุ่มเพิ่มลดจำนวน
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}