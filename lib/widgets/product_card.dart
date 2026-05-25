import 'package:flutter/material.dart';
import 'package:born2bake/models/product.dart';
import 'package:born2bake/screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  // สีโทนเขียวเข้มตาม Reference
  final Color priceColor = const Color(0xFF1F5C4D); 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
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
            // ส่วนรูปภาพ
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[50], // พื้นหลังรูปสีเทาอ่อนมาก
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain, // ให้รูปภาพแสดงเต็มใบโดยไม่ถูกตัด
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.grey, size: 50);
                    },
                  ),
                ),
              ),
            ),
            
            // ส่วนข้อความและราคา
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  
                  // แสดงราคา
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // ดันราคาไปชิดขวา
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '฿${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: priceColor,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          product.originalPrice!.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}