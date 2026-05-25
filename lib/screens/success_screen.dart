import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  final Color primaryGreen = const Color(0xFF2A5D50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ไอคอนเครื่องหมายถูก
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryGreen.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: primaryGreen,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                
                // ข้อความแสดงความสำเร็จ
                const Text(
                  'สั่งซื้อสำเร็จ!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ร้าน Borntobake.1998 ได้รับคำสั่งซื้อของคุณแล้ว\nเรากำลังเตรียมสินค้าให้คุณอย่างตั้งใจ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // ปุ่มกลับสู่หน้าแรก
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // กลับไปที่หน้าแรกสุดของแอปพลิเคชัน (MainScreen)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      'กลับสู่หน้าหลัก',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}