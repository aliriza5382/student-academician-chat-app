import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String loggedInUserId; // Giriş yapan kullanıcının ID'si
  final String userType; // Kullanıcı tipi: "student" veya "academician"

  const ChangePasswordScreen({
    required this.loggedInUserId,
    required this.userType,
    super.key,
  });

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifre ve tekrar eşleşmiyor.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kullanıcı koleksiyonunu belirle
      final collection = widget.userType == "student" ? "students" : "academicians";

      // Firestore'dan mevcut şifreyi al
      final userDoc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.loggedInUserId)
          .get();

      if (!userDoc.exists || userDoc['password'] != oldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eski şifre hatalı.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Yeni şifreyi güncelle
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.loggedInUserId)
          .update({'password': newPassword});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
      );

      Navigator.pop(context); // Şifre değişimi sonrası önceki ekrana dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
        backgroundColor: const Color(0x00ffffff),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Eski Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre (Tekrar)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Şifreyi Değiştir',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
