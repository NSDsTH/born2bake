import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:born2bake/providers/user_provider.dart';
import 'package:born2bake/screens/payment_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final Color primaryGreen = const Color(0xFF2A5D50);
  final Color primaryRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    // ถ้าเคยมีที่อยู่บันทึกไว้แล้ว ให้ดึงมาแสดงในช่องกรอกข้อความ
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.hasSavedAddress) {
      _addressController.text = userProvider.savedAddress;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ที่อยู่จัดส่ง',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ข้อมูลที่อยู่ของคุณ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // ช่องกรอกที่อยู่
              TextFormField(
                controller: _addressController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'บ้านเลขที่, ซอย, ถนน, ตำบล, อำเภอ, จังหวัด, รหัสไปรษณีย์',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // ปุ่มบันทึก
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกที่อยู่ก่อนดำเนินการต่อ')),
                      );
                      return;
                    }

                    // 1. บันทึกที่อยู่ลง Local Storage ผ่าน Provider
                    await Provider.of<UserProvider>(context, listen: false)
                        .saveAddress(_addressController.text.trim());
                    
                    if (!mounted) return;

                    // 2. ไปยังหน้า Payment 
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentScreen()),
                    );
                  },
                  child: const Text('บันทึกและดำเนินการต่อ', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}