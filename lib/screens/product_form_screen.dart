import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:born2bake/models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // ถ้ารับค่ามาแปลว่าเป็นการ Edit, ถ้าเป็น null แปลว่าเป็น Add

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _imageUrlController;
  
  String? _selectedCategoryId;
  bool _isOutOfStock = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // นำค่าเดิมมาตั้งต้นถ้าเป็นการแก้ไข
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _originalPriceController = TextEditingController(
      text: widget.product?.originalPrice != null ? widget.product!.originalPrice.toString() : ''
    );
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? 'assets/images/placeholder.png');
    _selectedCategoryId = widget.product?.categoryId;
    _isOutOfStock = widget.product?.isOutOfStock ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
        return;
      }

      setState(() => _isLoading = true);

      final Map<String, dynamic> productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'originalPrice': _originalPriceController.text.isNotEmpty ? double.tryParse(_originalPriceController.text) : null,
        'categoryId': _selectedCategoryId,
        'imageUrl': _imageUrlController.text.trim(),
        'isOutOfStock': _isOutOfStock,
      };

      try {
        if (widget.product == null) {
          // Create: เพิ่มสินค้าใหม่ โดยให้ Firestore สร้าง ID ให้อัตโนมัติ
          await _firestore.collection('products').add(productData);
        } else {
          // Update: แก้ไขข้อมูลสินค้าเดิมอ้างอิงตาม ID
          await _firestore.collection('products').doc(widget.product!.id).update(productData);
        }
        
        if (!mounted) return;
        Navigator.pop(context); // บันทึกเสร็จให้ปิดหน้าฟอร์ม
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'ชื่อสินค้า', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'รายละเอียด', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'ราคาขาย', border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty ? 'กรุณากรอกราคา' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _originalPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'ราคาปกติ (ถ้ามีลดราคา)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ดึง Category มาแสดงเป็น Dropdown
                    FutureBuilder<QuerySnapshot>(
                      future: _firestore.collection('categories').get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        
                        final categories = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                          items: categories.map((doc) {
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(doc['name']),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategoryId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Path รูปภาพ (เช่น assets/images/...)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('สินค้าหมด (Out of Stock)'),
                      value: _isOutOfStock,
                      onChanged: (value) => setState(() => _isOutOfStock = value),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A5D50)),
                        onPressed: _saveProduct,
                        child: const Text('บันทึกข้อมูล', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}